require 'test_helper'

describe Schedule do

  let(:schedule) { Schedule.new }

  it "creates an instance" do
    schedule.must_be_instance_of Schedule
  end

  describe "validations" do
    it "validates the time format" do
      [' 12:30 ', '1230', '-1:-1', 'abcd', "\n\n12:30\n\n", "\n12\n:30\n"].each do |time|
        schedule.monday = time
        schedule.valid?.must_equal false
      end

      %w{24:00 10:60 24:60}.each do |time|
        schedule.monday = time
        schedule.valid?.must_equal false
      end
    end
  end

end
