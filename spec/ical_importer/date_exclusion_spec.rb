require 'spec_helper'
module IcalImporter
  describe DateExclusion do
    subject { DateExclusion.new(attributes) }
    describe "#initialize" do
      describe "set the one valid attribute" do
        let(:attributes) { { :date_exclusion => "yerp" } }
        it "sets the date exlcusion" do
          subject.date_exclusion.should == "yerp"
        end
      end

      describe "try to set valid/invalid attributes" do
        let(:attributes) { { :date_exclusion => "yerp", :not_me => "nope" } }
        it "sets the date exlcusion" do
          subject.date_exclusion.should == "yerp"
          expect { subject.not_me }.to raise_error(NoMethodError)
        end
      end

      describe "set the one valid attribute" do
        let(:attributes) { { :not_me => "yerp", :or_me => "nope" } }
        it "sets the date exlcusion" do
          expect { subject.not_me }.to raise_error(NoMethodError)
          expect { subject.or_me }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
