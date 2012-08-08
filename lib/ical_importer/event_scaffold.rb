module IcalImporter
  class EventScaffold
    class << self
      attr_accessor :class_attributes
    end

    @class_attributes = [
      :uid,
      :title,
      :description,
      :location,
      :start_date_time,
      :end_date_time,
      :utc,
      :date_exclusions,
      :recur_end_date,
      :recur_month_repeat_by,
      :recur_interval,
      :recur_interval_value,
      :recur_end_date,
      :all_day_event
    ]

    attr_accessor *class_attributes
    DAYS = %w[sunday monday tuesday wednesday thursday friday saturday]

    DAYS.each do |day|
      class_attributes << "recur_week_#{day}".to_sym
      attr_accessor "recur_week_#{day}"
    end

    def initialize(attributes)
      self.attributes = attributes
    end

    def to_hash
      Hash[*self.class.class_attributes.collect do |attribute|
        [attribute.to_sym, send(attribute)]
      end.flatten]
    end

    def attributes=(attributes)
      attributes.each do |name, value|
        instance_variable_set "@#{name}", value if self.class.class_attributes.include? name.to_sym
      end
    end
  end
end
