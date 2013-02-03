###################
#
# This is the interface a robot needs to implement to work with
# the simulator
#
##################

class Robot
  #current position and size (radius) of the robot
  attr_reader :x,:y, :radius
  def initialize
    @x = 0
    @y = 0
    @radius = 10
  end

  def render
  end

  def born_in(*args)
  end

  def current_time
  end

  def step(time)


  end

end
