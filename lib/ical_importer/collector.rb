module IcalImporter
  class Collector
    attr_accessor :collection, :events

    def initialize(events)
      @events = events
      @collection = []
    end

    def collect
      recurring_builder = RecurringBuilder.new
      @collection = events.collect do |remote_event|
         Builder.new(remote_event, recurring_builder).build
      end
      @collection += recurring_builder.build.built_events
      @collection.flatten!.compact!
    end
  end
end
