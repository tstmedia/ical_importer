require 'spec_helper'
module IcalImporter
  describe LocalEvent do
    subject { LocalEvent.new(attributes) }
    describe "#init" do
      let(:attributes) { {} }
      it { should respond_to :uid }
      it { should respond_to :title }
      it { should respond_to :description }
      it { should respond_to :location }
      it { should respond_to :start_date_time }
      it { should respond_to :end_date_time }
      it { should respond_to :utc }
      it { should respond_to :date_exclusions }
      it { should respond_to :recur_end_date }
      it { should respond_to :recur_month_repeat_by }
      it { should respond_to :recur_interval }
      it { should respond_to :recur_interval_value }
      it { should respond_to :recur_end_date }
      it { should respond_to :recurrence_id }
      it { should respond_to :all_day_event }
      it { should respond_to :recurrence }
      it { should respond_to :recur_week_sunday }
      it { should respond_to :recur_week_monday }
      it { should respond_to :recur_week_tuesday }
      it { should respond_to :recur_week_wednesday }
      it { should respond_to :recur_week_thursday }
      it { should respond_to :recur_week_friday }
      it { should respond_to :recur_week_saturday }
    end
  end
end
