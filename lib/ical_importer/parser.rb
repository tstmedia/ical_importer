module IcalImporter
  class Parser
    attr_reader :feed, :bare_feed, :url

    def initialize(url)
      @url = url
      @bare_feed = open_ical
      if should_parse?
        @bare_feed.pos = 0
        @feed = RiCal.parse @bare_feed
      end
    end

    def should_parse?
      bare_feed.present?
    end

    def worth_parsing?
      should_parse? && feed.present? && feed.first
    end

    def all_events(&block)
      tap_and_each (@imported_single_events || []) + (@imported_recurrence_events || []), &block
    end

    def single_events(&block)
      tap_and_each (@imported_single_events || []), &block
    end

    def recurrence_events(&block)
      tap_and_each (@imported_recurrence_events || []), &block
    end

    def parse(&block)
      if worth_parsing?
        collected = Collector.new(feed.first.events).collect
        @imported_single_events = collected.single_events
        @imported_recurrence_events = collected.recurrence_events
        tap_and_each (@imported_single_events + @imported_recurrence_events), &block
      end
    end

    private

    def tap_and_each(list)
      list.tap do |r|
        r.each do |event|
          yield event if block_given?
        end
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

  end
end
