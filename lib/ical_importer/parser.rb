module IcalImporter
  class Parser
    attr_accessor :bare_feed,
      :feed, # Parsed
      :originator_id,
      :url,
      :after_parse,
      :finder

    def initialize(url, originator_id = nil)
      @url = url
      @bare_feed = open_ical
      @originator_id = originator_id
      if should_parse?
        @bare_feed.pos = 0
        @feed = RiCal.parse @bare_feed
      end
    end

    def open_ical(protocol = 'http')
      raise ArgumentError, "Must be http or https" unless %w[http https].include? protocol
      begin
        Timeout::timeout(5) do
          open prepped_uri(protocol)
        end
      rescue
        return open_ical 'https' if protocol == 'http'
        nil
      end
    end

    def prepped_uri(protocol)
      uri = url.strip.gsub(/^[Ww]ebcal:/, "#{protocol}:")
      uri = begin
              URI.unescape(uri)
            rescue URI::InvalidURIError
            end
      URI.escape(uri)
    end

    def feed_has_changed?
      feed = @bare_feed.gsub(/DTSTAMP:.*\s/, '')
      if Digest::MD5.hexdigest(feed) == Cache.get(CKey.ical_last_run_hash(@originator_id))
        false
      else
        Cache.put(CKey.ical_last_run_hash(@originator_id), Digest::MD5.hexdigest(feed))
        true
      end
    end

    def should_parse?
      @bare_feed.present? and feed_has_changed?
    end

    def parse
      if should_parse?
        if @feed.present?
          calendar = @feed.first

          imported_events = Collector.new(calendar).collect

          imported_events.each do |event|
            yield event
          end

          # TODO Make a callback
          # find & destroy any events that where created by this feed but arent' in there anymore
          query = Event.where(:ical_feed_id => self.id)
          if imported_events.length > 0
            query.where(["id NOT IN (?)", imported_events.map(&:id)])
          end
          Ngin.log :ical_feed,
            object: self,
            message: "Destroy all",
            custom_fields: {
              deleting: query.collect { |x| [x.try(:id), x.try(:title)] },
              keeping: imported_events.collect { |x| [x.try(:id), x.try(:title)] }
            }
            query.destroy_all
        end

        update_attributes(:last_run_at => DateTime.now)
        imported_events
      else
        Ngin.log :ical_feed,
          :object => self,
          :message => "Remote calendar was empty, failing silently"
        false
      end
    end
  end
end
