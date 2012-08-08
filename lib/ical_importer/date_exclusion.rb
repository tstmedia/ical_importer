module IcalImporter
  class DateExclusion
    attr_accessor :date_exclusion

    def initialize(attributes)
      attributes.each do |name, value|
        instance_variable_set "@#{name}", value if [:date_exclusion].includ? name.to_sym
      end
    end
  end
end
