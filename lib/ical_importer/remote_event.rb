module IcalImporter
  class RemoteEvent
    attr_accessor :event, :utc
    alias :utc? :utc
    delegate :recurs?, :rrule_property, :exdate, :to => :event

    def initialize(event)
      @event = event
      begin
        @utc = @event.dtstart.try(:tzid) != :floating
      rescue
        @utc = true
      end
    end

    def start_date_time
      if event.dtstart.is_a? DateTime
        event.dtstart.tzid == :floating ? event.dtstart : event.dtstart.utc
      else
        event.dtstart.to_datetime
      end
    end

    def end_date_time
      if event.dtend.is_a? DateTime
        (event.dtend.tzid == :floating) ? event.dtend : event.dtend.utc
      else
        event.dtend.to_datetime
      end
    end

    def all_day_event?
      (end_date_time.day - start_date_time.day) > 1.day
    end

    def event_attributes
      {
        :title => event.summary,
        :utc => utc?,
        :description => event.description,
        :location => event.location || '',
        :start_date_time => start_date_time,
        :end_date_time => end_date_time,
        :all_day_event => all_day_event?
      }
    end
  end
end
