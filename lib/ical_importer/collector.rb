module IcalImporter
  class Collector
    attr_accessor :collection, :events

    def initialize(events)
      @events = events
      @collection = []
    end

    def collect
      recurring_builder = RecurringBuilder.new
      @collection.tap do |c|
        events.each do |remote_event|
          c << Builder.new(remote_event, recurring_builder).build
        end
        c += recurring_builder.build.built_events
        c.flatten!
        c.compact!
      end
    end
  end
end
