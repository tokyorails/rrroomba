##############################
#
#  This class represents the virtual world our simulation runs in
#
##############################
class World

  def initialize
    @robots = []
    read_world
    self
  end

  def render
    world_ui = {}
    world_ui['boundaries'] = @boundaries
    world_ui['obstacles'] = @obstacles
    @robots.each do |r|
      world_ui['robot'] = r.render
    end
    world_ui.to_json
  end

  def spawn(*robots)
    robots.each do |bot|
      @robots.push(bot)
    end
  end

  def robot(index=0)
    @robots[index]
  end

  def step (time_step)
    @robots.each do |robot|
      robot.step(time_step)
      if collision_with?(robot)
        robot.step_back
      end
    end
  end


  def collision_with?(robot)

    @boundaries.each do |boundary|
      distance_to_boundary = boundary.distance_to(robot.pos) - robot.radius
      return true if distance_to_boundary <= 0
    end

    @obstacles.each do |z|
      distance = z.position.distance_to(robot.pos)
      return true if distance <= (z.radius + robot.radius)
    end
    false
  end

  private

  def read_world
    #TODO: read from external .yml or something
    #TODO: mass and shape for the obstacles
    #boundaries from left boundary clockwise.
    @boundaries = [
      Plane.new(Vector.new(1,0), 1000),
      Plane.new(Vector.new(0,-1), 800),
      Plane.new(Vector.new(-1,0), 1000),
      Plane.new(Vector.new(0,1), 800)
    ]
    @obstacles = [
      Circle.new(Position.new(0,500), 20),
      Circle.new(Position.new(300,0), 20),
      Circle.new(Position.new(-900,-700), 10)
    ]
  end

end
