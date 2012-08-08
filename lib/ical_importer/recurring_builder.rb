module IcalImporter
  class RecurringBuilder
    attr_accessor :events_to_build, :built_events
    def initialize
      @events_to_build = []
      @built_events = []
    end

    def <<(event)
      @events_to_build << event
    end

    def build
      # TODO
      # raise "iCal feed (#{id}) does not contain UID" if remote_event.uid.blank?
      @events_to_build.each do |remote_event|
        if recurring_event = Event.find_by_ical_uid(remote_event.uid)
          @built_events << build_new_local_event(remote_event)
        end
      end
      self
    end

    private

    def build_new_local_event(remote_event)
      local_event = EventScaffold.new({
        #:ical_feed => self, # TODO
        :title => remote_event.summary,
        :description => local_event.description,
        :location => remote_event.location || '',
        :start_date_time => local_event.start_date_time,
        :end_date_time => local_event.end_date_time,
        :date_exclusions => [DateExclusion.new(:exclude_date => remote_event.recurrence_id)]
      })
      #local_event.page_nodes = self.page_nodes # overwrite event's tags # TODO GET ME SOME IDS
    end
  end
end
