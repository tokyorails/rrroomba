require 'test_helper'

# TO RUN:
# ruby -Itest test/unit/roomba_serial_simulation_test.rb

# We should really test that @moving and the like cannot be set but
# the best way to do that would be shared tests between both initialization
# types and I am not totally sure how to do that with minitest

describe RoombaSerialSimulation do

  describe 'basic initialization' do

    let(:roomba_serial) do
       RoombaSerialSimulation.new
    end

    it "creates an instance" do
      roomba_serial.must_be_instance_of RoombaSerialSimulation
    end

    it "should set the simulation" do
      roomba_serial.simulation.must_equal 'simulation'
    end

    it "should set the x position" do
      roomba_serial.x.must_equal 0
    end

    it "should set the y position" do
      roomba_serial.y.must_equal 0
    end

    it "should set the facing" do
      roomba_serial.facing.must_equal 0
    end

  end

  describe 'config block initialization' do

    let(:roomba_serial) do
       RoombaSerialSimulation.new do |config|
         config.simulation = 'simulation-test'
         config.x = 5
         config.y = 5
         config.facing = 90
      end
    end

    it "creates an instance" do
    roomba_serial.must_be_instance_of RoombaSerialSimulation
    end

    it "should set the simulation" do
      roomba_serial.simulation.must_equal 'simulation-test'
    end

    it "should set the x position" do
      roomba_serial.x.must_equal 5
    end

    it "should set the y position" do
      roomba_serial.y.must_equal 5
    end

    it "should set the facing" do
      roomba_serial.facing.must_equal 90
    end

  end

end

