module IcalImporter
  class SingleEvent
    attr_accessor :event, :recurring_builder, :local_event

    def initialize(event, recurring_builder)
      @event = Construct.new event # AKA Remote Event
      @recurring_builder = recurring_builder

      # simple validity check
      # TODO
      # raise "iCal feed (#{id}) does not contain UID" if remote_event.uid.blank?
      # find and overwrite the event created by this remote event
      #@local_event = Event.find_or_initialize_by_ical_uid event.uid

      attributes = { :uid => event.uid }.merge @event.event_attributes
      @local_event = EventScaffold.new attributes
    end

    # Get single-occurrence events built and get a lits of recurring
    # events, these must be build last
    def build
      # handle recuring events
      if @event.recurs?
        rrule = remote_event.rrule_property.first # only support recurring on one schedule
        # set out new event's basic rucurring properties
        @local_event.attributes = recurring_attributes

        set_date_exclusion
        frequency_set rrule
      else # make sure we remove this if it changed
        @local_event.attributes = non_recurring_attributes
      end
      #@local_event.page_nodes = self.page_nodes # overwrite event's tags #TODO GET FROM ORIGINAL OBJ

      @local_event
    end

    private

    def non_recurring_attributes
      attributes = {
        :recur_interval => "none",
        :recur_interval_value => nil,
        :recur_end_date => nil
      }
      if !@local_event.all_day_event && @event.start_date_time.day != @event.end_date_time.day # single event that spans multiple days
        attributes.merge {
          :recur_interval => "day",
          :recur_interval_value => 1,
          :recur_end_date => @event.end_date_time.end_of_day - 1.day,
          :all_day_event => true
        }
      end
      attributes
    end

    def recurring_attributes(rrule)
      {
          :recur_interval => recur_map[rrule.freq],
          :recur_interval_value => rrule.interval,
          :recur_end_date => rrule.until.try(:to_datetime)
        }
    end

    def set_date_exclusion
      # set any date exclusions
      @local_event.date_exclusions = remote_event.exdate.flatten.map{|d| DateExclusion.new(:exclude_date => d)}
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
          # recurring X times is probably broken - we can select multiple times in a week
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
