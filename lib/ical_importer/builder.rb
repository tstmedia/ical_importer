module IcalImporter
  class Builder
    attr_reader :event, :recurrence_builder
    def initialize(event, recurrence_builder)
      @event = event
      @recurrence_builder = recurrence_builder
    end

    def handle_as_recurrence?
      event.recurrence_id.present?
    end

    def build
      if handle_as_recurrence?
        recurrence_builder << event
        nil # Don't want this messing up our collect in Collector
      else
        SingleEventBuilder.new(event).build
      end
    end
  end
end
