
require 'test_helper'

describe Simulation do
  before(:each) do
    @simulation = Simulator.new
    @roo = RoombaSimulation.new
    @simulation.add_robot(@roo)
  end

  it "can be started and stopped" do
    @simulation.start
    @simulation.running?.must_equal true
    @simulation.stop
    @simulation.running?.must_equal false
  end


  it "should not move the robot if the simulation has not started" do
    @roo.move(50)
    sleep(0.1)
    @roo.x.must_equal 0
    @roo.y.must_equal 0
  end


  it "must spawn the robot into 0,0" do
    @simulation.start
    @roo.x.must_equal 0
    @roo.y.must_equal 0
    @simulation.stop
  end

  it "should move in a straight line" do
    @simulation.start
    @roo.move(50)
    sleep 0.3
    @roo.x.must_equal 0
    @roo.y.must_equal 50
  end


end
