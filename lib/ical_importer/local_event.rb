module IcalImporter
  class LocalEvent
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
      :recurrence_id,
      :all_day_event,
      :recurrence
    ]

    attr_accessor *class_attributes
    DAYS = %w[sunday monday tuesday wednesday thursday friday saturday]

    DAYS.each do |day|
      class_attributes << "recur_week_#{day}".to_sym
      attr_accessor "recur_week_#{day}"
    end

    def initialize(attributes)
      self.attributes = attributes
      @date_exclusions ||= []
    end

    def get_attributes(list)
      attributes.select { |k,_| list.include? k.to_s }
    end

    def to_hash
      Hash[*self.class.class_attributes.collect { |attribute| [attribute.to_sym, send(attribute)] }.flatten(1)]
    end
    alias :attributes :to_hash

    def attributes=(attributes)
      attributes.each do |name, value|
        instance_variable_set "@#{name}", value if self.class.class_attributes.include? name.to_sym
      end
    end
  end
end
