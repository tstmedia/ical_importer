module IcalImporter
  class Collector
    attr_accessor :single_events, :events, :recurrence_events

    def initialize(events)
      @events = events
      @single_events = []
      @recurrence_events = []
    end

    def collect
      self.tap do
        recurrence_builder = RecurrenceEventBuilder.new
        @single_events.tap do |c|
          events.each do |remote_event|
            c << Builder.new(remote_event, recurrence_builder).build
          end
          @recurrence_events = recurrence_builder.build.built_events.flatten.compact
          c.flatten!
          c.compact!
        end
      end
    end
  end
end
