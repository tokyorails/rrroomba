######################################
# This class represent a bumper sensor (it returns collisions when
# touching something)
#####################################
class Bumper
  # The robot we belong to, the angle where the bumper is installed
  # in case the bumper has an extension, lenght of it
  # and the world we belong to
  def initialize(robot, angle, lenght, world)
    @robot, @angle, @lenght, @world = robot, angle, lenght, world
  end

  def got_collisions?
    positions_to_test.any?{ |pos| @world.collision_with?(pos) }
  end

  private
  def positions_to_test
    [bumper_position(@angle-lenght), bumper_position(@angle), bumper_position(@angle+lenght)]
  end

  def bumper_position(angle)
    bumper_x = @robot.pos.x + @robot.radius * Math.cos(world_angle(angle))
    bumper_y = @robot.pos.y + @robot.radius * Math.sin(world_angle(angle))
    Position.new(bumper_x, bumper_y)
  end

  def world_angle(angle)
    Angle.degrees_to_radians(@robot.pose.angle + angle)
  end

end
