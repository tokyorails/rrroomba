require 'test_helper'

# TO RUN:
# ruby -Itest test/unit/roomba_simulation.rb

describe RoombaSimulation do
  let(:roomba) { RoombaSimulation.new }

  it "creates an instance" do
    roomba.must_be_instance_of RoombaSimulation
  end


  describe "#set_velocity" do
    it "sets related variables" do
      vars = [:velocity_hex, :velocity_high, :velocity_low]
      vars.each {|v| roomba.send(v).must_be_nil }
      roomba.set_velocity(200)
      vars.each {|v| roomba.send(v).wont_be_nil }
    end

    it "sets the hexa value" do
      roomba.velocity_hex.must_be_nil
      roomba.set_velocity(100)
      roomba.velocity_hex.must_equal "%04X" % 100
    end

    it "adjusts values if the given velocity is too high" do
      roomba.velocity_hex.must_be_nil
      roomba.set_velocity(1000)
      roomba.velocity_hex.must_equal "%04X" % 500
    end
  end


  describe "#set_degree" do
    it "sets related variables" do
      vars = [:radius_hex, :radius_high, :radius_low]
      vars.each {|v| roomba.send(v).must_be_nil }
      roomba.set_degree(0)
      vars.each {|v| roomba.send(v).wont_be_nil }
    end

    it "sets the hexa value" do
      roomba.radius_hex.must_be_nil
      roomba.set_degree(0)
      roomba.radius_hex.must_equal "%04X" % 32768
    end
  end


  describe "#signed_integer" do
    it "returns an 8bit signed integer" do
      roomba.signed_integer([255]).must_equal -1
      roomba.signed_integer([120]).must_equal 120
    end

    it "returns a 16bit signed integer" do
      roomba.signed_integer([255,106]).must_equal -150
      roomba.signed_integer([1,44]).must_equal 300
    end
  end


  describe "cleaning schedule" do
    it "does nothing if passed no days" do
      roomba.schedule_cleaning.must_be_nil
    end

    it "schedules a couple of days" do
      roomba.schedule_cleaning(
        :monday => '10:00', :tuesday => '13:30', :monday => '12:00'
      ).must_equal [6, 0, 0, 12, 0, 13, 30, 0, 0, 0, 0, 0, 0, 0, 0]

      roomba.schedule_cleaning(
        'tuesday' => '13:30', 'monday' => '12:00'
      ).must_equal [6, 0, 0, 12, 0, 13, 30, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    it "schedules all days" do
      roomba.schedule_cleaning(
        :monday => '10:01', :tuesday => '11:11', :wednesday => '12:21', :thursday => '13:31', :friday => '14:41', :saturday => '15:51', :sunday => '16:00'
      ).must_equal [127, 16, 0, 10, 1, 11, 11, 12, 21, 13, 31, 14, 41, 15, 51]
    end

    it "clears all days" do
      roomba.clear_schedule.must_equal [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    end

  end
end
