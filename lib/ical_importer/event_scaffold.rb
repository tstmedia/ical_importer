module IcalImporter
  class EventScaffold
    class << self
      attr_accessor :class_attributes
    end

    class_attributes  = [
      :title,
      :description,
      :location,
      :start_date_time,
      :end_date_time,
      :date_exclusions,
      :recur_end_date,
      :recur_month_repeat_by,
      :recur_interval,
      :recur_interval_value,
      :recur_end_date,
      :all_day_event
    ]

    attr_accessor *self.class.class_attributes
    DAYS = %w[sunday monday tuesday wednesday thursday friday saturday]

    DAYS.each do |day|
      class_attributes << "recur_week_#{day}".to_sym
      attr_accessor "recur_week_#{day}"
    end

    def initialize(attributes)
      attributes.each do |name, value|
        instance_variable_set "@#{name}", value if self.class.attributes.include? name.to_sym
      end
    end
  end
end
