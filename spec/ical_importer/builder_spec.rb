require 'spec_helper'
module IcalImporter
  describe Builder do
    subject { Builder.new(event, recurrence_builder) }
    let(:recurrence_builder) { RecurrenceEventBuilder.new }

    describe "#handle_as_recurrence?" do
      describe "recurrence_id'd event" do
        let(:event) { stub :recurrence_id => 1 }
        it "handles as recurrence" do
          subject.handle_as_recurrence?.should == true
        end
      end

      describe "non-recurrence_id'd event" do
        let(:event) { stub :recurrence_id => nil }
        it "handles as recurrence" do
          subject.handle_as_recurrence?.should == false
        end
      end
    end

    describe "#build" do
      let(:event) { stub }
      describe "recurrence" do
        let(:event) { stub :recurrence_id => 1 }
        it "adds events to be computed with recurrence_builder" do
          recurrence_builder.should_receive(:<<).with(event)
          subject.build.should == nil
        end
      end

      describe "non-recurrence" do
        let(:event) { stub :recurrence_id => nil }
        it "builds single event" do
          single_event_builder = stub
          returned = stub
          SingleEventBuilder.should_receive(:new).with(event).and_return single_event_builder
          single_event_builder.should_receive(:build).and_return(returned)
          subject.build.should == returned
        end
      end
    end
  end
end
