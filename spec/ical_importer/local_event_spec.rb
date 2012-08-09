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
      it { should respond_to :uid= }
      it { should respond_to :title= }
      it { should respond_to :description= }
      it { should respond_to :location= }
      it { should respond_to :start_date_time= }
      it { should respond_to :end_date_time= }
      it { should respond_to :utc= }
      it { should respond_to :date_exclusions= }
      it { should respond_to :recur_end_date= }
      it { should respond_to :recur_month_repeat_by= }
      it { should respond_to :recur_interval= }
      it { should respond_to :recur_interval_value= }
      it { should respond_to :recur_end_date= }
      it { should respond_to :recurrence_id= }
      it { should respond_to :all_day_event= }
      it { should respond_to :recurrence= }
      it { should respond_to :recur_week_sunday= }
      it { should respond_to :recur_week_monday= }
      it { should respond_to :recur_week_tuesday= }
      it { should respond_to :recur_week_wednesday= }
      it { should respond_to :recur_week_thursday= }
      it { should respond_to :recur_week_friday= }
      it { should respond_to :recur_week_saturday= }

      describe "#get_attributes" do
        let(:attributes) { { :uid => 1, :title => 'winner', :utc => true } }
        it "selects some attributes" do
          subject.get_attributes(['utc', :uid]).should == { :uid => 1, :utc => true }
        end

        it "gets and empty hash" do
          subject.get_attributes(['doesnt exist']).should == { }
        end

        it "sends an empty array" do
          subject.get_attributes([]).should == { }
        end

        it "doesn't send an array" do
          expect { subject.get_attributes({}) }.to raise_error(ArgumentError, "Must be an Array")
        end
      end

      describe "#to_hash" do
        let(:attributes) { { :uid => 1, :title => "winner" } }
        it "should return all of the attributes" do
          subject.to_hash.should == {
            :uid => 1,
            :title => "winner",
            :description => nil,
            :location => nil,
            :start_date_time => nil,
            :end_date_time => nil,
            :utc => nil,
            :date_exclusions => [], # Set in initializer
            :recur_end_date => nil,
            :recur_month_repeat_by => nil,
            :recur_interval => nil,
            :recur_interval_value => nil,
            :recur_end_date => nil,
            :recurrence_id => nil,
            :all_day_event => nil,
            :recurrence => nil,
            :recur_week_sunday => nil,
            :recur_week_monday => nil,
            :recur_week_tuesday => nil,
            :recur_week_wednesday => nil,
            :recur_week_thursday => nil,
            :recur_week_friday => nil,
            :recur_week_saturday => nil
          }
        end
      end

      describe "#attributes=" do
        let(:attributes) { { :uid => 1, :title => "winner" } }
        it "sets a few attributes" do
          subject.attributes = { :uid => 2, :description => "we got 'em" }
          subject.uid.should == 2
          subject.attributes[:uid].should == 2
          subject.title.should == "winner"
          subject.attributes[:title].should == "winner"
          subject.description.should == "we got 'em"
          subject.attributes[:description].should == "we got 'em"
        end

        it "sets the acceptable attributes, not the unacceptable" do
          subject.attributes = { :dont => "use", :me => "ha", :uid => 3 }
          subject.uid.should == 3
          subject.attributes[:uid].should == 3
          subject.attributes[:dont].should == nil
          subject.attributes[:me].should == nil
        end
      end
    end
  end
end
