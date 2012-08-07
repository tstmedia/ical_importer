module IcalImporter
  class Builder
    attr_accessor :event, :recurring_builder
    def initialize(event, recurring_builder)
      @event = event
      @recurring_builder = recurring_builder
    end

    # If an event has a recurrence_id it is a special case (ie modified summary) and potentially will override the real recurrence.
    # Creating an exclusion for the event and treating it
    def handle_as_recurring?
      @event.recurrence_id.present?
    end

    def build
      if handle_as_recurring?
        @recurring_builder << event
      else
        SingleEvent.new(@event, @recurring_builder).build_event
      end
    end
  end
end
