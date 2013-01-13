
require 'test_helper'

describe Simulation do
  before(:each) do
    @simulation = Simulator.new
    @roo = RoombaSimulation.new
    @simulation.add_robot(@roo)
  end

  after(:each) do
    @simulation.stop
  end

  it "can be started and stopped" do
    @simulation.start
    @simulation.running?.must_equal true
    @simulation.stop
    @simulation.running?.must_equal false
  end
=begin
  it "should not move the robot if the simulation has not started" do
    @roo.move(50)
    sleep(0.1)
    @roo.x.must_equal 0
    @roo.y.must_equal 0
  end
=end

  it "must spawn the robot into 0,0" do
    @simulation.start
    @roo.x.must_equal 0
    @roo.y.must_equal 0
  end
=begin
TODO
  it "should move in a straight line" do
    @simulation.start
    @roo.move(50)
    @roo.x.must_equal 50
    @roo.y.must_equal 0
  end
=end


end
