require 'test_helper'

# TO RUN:
# ruby -Itest test/unit/world_test.rb

describe World do

  describe 'basic initialization' do

    let(:world) do
       World.new(RoombaSimulation.new)
    end

    it "creates an instance" do
      world.must_be_instance_of World
    end

    it "should create a default robot" do
      world.robot.must_be_instance_of RoombaSimulation
    end

    it "should not create more than 1 initial robot" do
      world.robot(1).must_equal nil
    end

    it "should render the boundaries" do
      world.render.include?("boundaries").must_equal true
    end

    it "should render the obstacles" do
      world.render.include?("obstacles").must_equal true
    end
  end

end

