require 'test_helper'

# TO RUN:
# ruby -Itest test/unit/roomba_serial_simulation.rb

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

    it "should set the boundaries" do
      roomba_serial.boundaries.must_equal [1000, -1000, 800, -800]
    end

    it "should set the obstacles" do
      roomba_serial.obstacles.must_equal [[0, 500, 20],[300, 0, 20],[-900, -700, 10]]
    end     

  end

  describe 'config block initialization' do

    let(:roomba_serial) do
       RoombaSerialSimulation.new do |config|
         config.simulation = 'simulation-test'
         config.x = 5
         config.y = 5
         config.facing = 90
         config.boundaries = [2000, -2000, 1600, -1600]
         config.obstacles = [[0, 700, 20],[500, 0, 20],[-600, -700, 10]]
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

    it "should set the boundaries" do
      roomba_serial.boundaries.must_equal [2000, -2000, 1600, -1600]
    end

    it "should set the obstacles" do
      roomba_serial.obstacles.must_equal [[0, 700, 20],[500, 0, 20],[-600, -700, 10]]
    end        

  end

end

