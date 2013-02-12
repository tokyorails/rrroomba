######################################
# This class represent a bumper sensor (it returns collisions when
# touching something)
#####################################
# TODO: At this moment checks the whole robot.
class Bumper
  def initialize(robot, world)
    @robot = robot
    @world = world
  end

  def got_collisions?
    @world.collision_with?(@robot)
  end

end
