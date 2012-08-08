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

    def should_parse?
      @bare_feed.present?
    end

    def worth_parsing?
      should_parse? && @feed.present? && @feed.first
    end

    def single_events
      @imported_single_events.tap do |s|
        s.each do |event|
          yield event if block_given?
        end
      end
    end

    def recurring_events
      @imported_recurring_events.tap do |r|
        r.each do |event|
          yield event if block_given?
        end
      end
    end

    def parse
      if should_parse?
        if @feed.present? and calendar = @feed.first
          collected = Collector.new(calendar.events).collect

          @imported_single_events = collected.single_events
          @imported_recurring_events = collected.recurring_events

          (@imported_single_events + @imported_recurring_events).each do |event|
            yield event if block_given?
          end
        end
      end
    end
  end
end
