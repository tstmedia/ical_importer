module IcalImporter
  class SingleEventBuilder
    attr_accessor :event, :recurrence_builder, :local_event

    def initialize(event, recurrence_builder)
      @event = RemoteEvent.new event # AKA Remote Event
      @recurrence_builder = recurrence_builder
      attributes = { :uid => event.uid }.merge @event.event_attributes
      @local_event = LocalEvent.new attributes
    end

    # Get single-occurrence events built and get a lits of recurrence
    # events, these must be build last
    def build
      # handle recuring events
      @local_event.tap do |le|
        if @event.recurs?
          rrule = @event.rrule_property.first # only support recurrence on one schedule
          # set out new event's basic rucurring properties
          le.attributes = recurrence_attributes rrule

          set_date_exclusion
          frequency_set rrule
        else # make sure we remove this if it changed
          le.attributes = non_recurrence_attributes
        end
      end
    end

    private

    def non_recurrence_attributes
      attributes = {
        :recur_interval => "none",
        :recur_interval_value => nil,
        :recur_end_date => nil
      }
      if !@local_event.all_day_event && @event.start_date_time.day != @event.end_date_time.day # single event that spans multiple days
        attributes.merge({
          :recur_interval => "day",
          :recur_interval_value => 1,
          :recur_end_date => @event.end_date_time.end_of_day - 1.day,
          :all_day_event => true
        })
      end
      attributes
    end

    def recurrence_attributes(rrule)
      {
        :recur_interval => recur_map[rrule.freq],
        :recur_interval_value => rrule.interval,
        :recur_end_date => rrule.until.try(:to_datetime)
      }
    end

    def set_date_exclusion
      # set any date exclusions
      @local_event.date_exclusions = @event.exdate.flatten.map{|d| DateExclusion.new(:exclude_date => d)}
    end

    def frequency_set(rrule)
      # if .bounded? is an integer that's googles "recur X times"
      # if that's the case we try to figure out the date it should be by
      # multiplying thise "X" times by the frequency that the event recurrs
      if rrule.bounded?.is_a? Fixnum # convert X times to a date
        case rrule.freq
        when "DAILY"
          @local_event.recur_end_date = frequency_template.days
        when "WEEKLY"
          if rrule.to_ical.include?("BYDAY=")
            remote_days = rrule.to_ical.split("BYDAY=").last.split(";WKST=").first.split(',')
            day_map.each do |abbr, day|
              @local_event.send "recur_week_#{day}=", remote_days.include?(abbr)
            end
          else
            remote_days = [@local_event.start_date_time.wday]
            wday_map.each do |abbr, day|
              @local_event.send "recur_week_#{day}=", remote_days.include?(abbr)
            end
          end
          # recurrence X times is probably broken - we can select multiple times in a week
          @local_event.recur_end_date = (frequency_template / remote_days.length).weeks
        when "MONTHLY"
          @local_event.recur_month_repeat_by = (rrule.to_ical =~ /BYDAY/) ? "day_of_week" : "day_of_month"
          @local_event.recur_end_date = frequency_template.months
        when "YEARLY"
          @local_event.recur_end_date = frequency_template.years
        end
      end
    end

    def frequency_template
      @local_event.start_date_time + (rrule.bounded? * rrule.interval - 1)
    end

    def recur_map
      {
        "DAILY" => "day",
        "WEEKLY" => "week",
        "MONTHLY" => "month",
        "YEARLY" => "year"
      }
    end

    def day_map
      {
        "SU" => "sunday",
        "MO" => "monday",
        "TU" => "tuesday",
        "WE" => "wednesday",
        "TH" => "thursday",
        "FR" => "friday",
        "SA" => "saturday"
      }
    end

    def wday_map
      {
        0 => "sunday",
        1 => "monday",
        2 => "tuesday",
        3 => "wednesday",
        4 => "thursday",
        5 => "friday",
        6 => "saturday"
      }
    end
  end
end
