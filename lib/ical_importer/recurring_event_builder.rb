module IcalImporter
  class RecurringEventBuilder
    attr_accessor :events_to_build, :built_events
    def initialize
      @events_to_build = []
      @built_events = []
    end

    def <<(event)
      @events_to_build << event
    end

    def build
      @events_to_build.each do |remote_event|
        @built_events << build_new_local_event(remote_event)
      end
      self
    end

    private

    def build_new_local_event(remote_event)
      local_event = LocalEvent.new({
        :title => remote_event.summary,
        :description => local_event.description,
        :location => remote_event.location || '',
        :start_date_time => local_event.start_date_time,
        :end_date_time => local_event.end_date_time,
        :date_exclusions => [DateExclusion.new(:exclude_date => remote_event.recurrence_id)],
        :recurring => true
      })
    end
  end
end
