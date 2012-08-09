require 'spec_helper'
module IcalImporter
  describe Collector do
    let(:events) { [] }
    subject { Collector.new events }
    it { should respond_to :collect }

    describe "#collect" do
      let(:events) { [stub, stub] }
      let(:r_builder) { stub(:build => stub(:built_events => [])) }
      it "tries to build, then cleanup the returns" do
        built = stub
        RecurrenceEventBuilder.should_receive(:new).and_return r_builder
        Builder.should_receive(:new).with(events[0], r_builder).ordered.and_return(built)
        Builder.should_receive(:new).with(events[1], r_builder).ordered.and_return(built)
        built.should_receive(:build).twice.and_return "boom"
        subject.collect
      end
    end
  end
end
