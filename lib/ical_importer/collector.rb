module IcalImporter
  class Collector
    attr_accessor :single_events, :events, :recurring_events

    def initialize(events)
      @events = events
      @single_events = []
      @recurring_events = []
    end

    def collect
      self.tap do
        recurring_builder = RecurringEventBuilder.new
        @single_events.tap do |c|
          events.each do |remote_event|
            c << Builder.new(remote_event, recurring_builder).build
          end
          @recurring_events = recurring_builder.build.built_events.flatten.compact
          c.flatten!
          c.compact!
        end
      end
    end
  end
end
