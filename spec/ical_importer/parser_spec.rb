require 'spec_helper'
require 'timeout'
module IcalImporter
  describe Parser do
    subject { Parser.new(url) }
    let(:url) { "http://some_url" }
    let(:bare_stuff) { stub :pos= => true }
    before do
      ::Timeout.stub!(:timeout).and_yield
    end

    describe '#initialize' do
      it "parses with rical" do
        Parser.any_instance.stub(:open_ical).and_return bare_stuff
        RiCal.should_receive(:parse).with bare_stuff
        Parser.new(url)
      end
    end

    describe "#should_parse?" do
      it "should parse" do
        subject.stub :bare_feed => bare_stuff
        subject.should_parse?.should == true
      end

      context "empty base_feed" do
        it "is false" do
          subject.stub :base_feed => nil
          subject.should_parse?.should == false
        end
      end
    end

    describe "#worth_parsing?" do
      it "should be parsed" do
        feed = stub :present? => true, :first => true
        subject.stub :feed => feed, :should_parse? => true
        subject.worth_parsing?.should == true
      end
    end

    describe "#all_events" do
      let(:url) { sample_ics_path }
      it "has all 3 events" do
        subject.parse
        subject.all_events.count.should == 3
      end
    end

    describe "#single_events" do
      let(:url) { sample_ics_path }
      it "has the 3 singluar events" do
        subject.parse
        subject.single_events.count.should == 3
      end
    end

    # Need to find a good example feed with recurrence_id set
    describe "#recurrence_events" do
      let(:url) { sample_ics_path }
      it "has 0 recurrence_events" do
        subject.parse
        subject.recurrence_events.count.should == 0
      end
    end

    describe "#parse" do
      let(:url) { sample_ics_path }
      it "returns 3 events" do
        subject.parse.count.should == 3
      end

      it "can use a block to manipulate events" do
        count = 0
        subject.parse do |e|
          e.should be_an_instance_of LocalEvent
          count += 1
        end
        count.should == 3
      end
    end

    describe "#open_ical" do
      it 'cleans up and tries to open an HTTP URL' do
        subject.stub :open => bare_stuff
        subject.send(:open_ical).should == bare_stuff
      end

      it "fails with an invalid protocol" do
        expect { subject.send(:open_ical, 'wrong_proto') }.to raise_error(ArgumentError, "Must be http or https")
      end
    end

    describe "#prepped_uri" do
      it "spits back the http URL" do
        subject.send(:prepped_uri, 'http').should == url
      end

      describe "https" do
        let(:url) { "https://some_url" }
        it "spits back the https URL" do
          subject.send(:prepped_uri, 'https').should == url
        end
      end

      describe "webcal" do
        let(:base_url) { "://some_url" }
        let(:http_url) { "http#{base_url}" }
        let(:url) { "webcal#{base_url}" }
        it "spits back the http URL" do
          subject.send(:prepped_uri, 'http').should == http_url
        end
      end

      describe "Webcal" do
        let(:base_url) { "://some_url" }
        let(:http_url) { "http#{base_url}" }
        let(:url) { "Webcal#{base_url}" }
        it "spits back the http URL" do
          subject.send(:prepped_uri, 'http').should == http_url
        end
      end
    end
  end
end
