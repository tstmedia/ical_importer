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
          DateExclusion.create(:exclude_date => remote_event.recurrence_id, :event_id => recurring_event.id)
          safe_save recurring_event
          @built_events << build_new_local_event(remote_event)
        end
      end
      self
    end

    private

    def build_new_local_event(remote_event)
      local_event = Event.new
      local_event.attributes = {
        :ical_feed => self,
        :title => remote_event.summary,
        :description => local_event.description,
        :location => remote_event.location || '',
        :start_date_time => local_event.start_date_time,
        :end_date_time => local_event.end_date_time
      }
      local_event.page_nodes = self.page_nodes # overwrite event's tags # TODO GET ME SOME IDS
      safe_save local_event
    end

    def safe_save(object)
      begin
        object.save!
      rescue ActiveRecord::RecordNotUnique => e
        Ngin.log :ical_feed,
          :object => recurring_event,
          :error => object,
          :message => "Duplicate key error",
          :custom_fields => object.attributes
      end
      object unless object.new_record?
    end
  end
end
