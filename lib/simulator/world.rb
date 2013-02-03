##############################
#
#  This class represents the virtual world our simulation runs in
#
##############################
class World
  attr_accessor :time

  def initialize(*roombots)
    @robots = []
    read_world
    roombots.each do |bot|
      spawn(bot)
    end
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

  def spawn(robot)
    @robots.push(robot)
    robot.born_in self
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
    x = robot.x
    y = robot.y
    radius = robot.radius

    if (@boundaries[0] - x).abs == radius || (@boundaries[1] - x).abs == radius || (@boundaries[2] - y).abs == radius || (@boundaries[3] - y).abs == radius
      return true
    end
    @obstacles.each do |z|
      distance = Math.sqrt((x - z[:x])**2 + (y - z[:y])**2) # Pythagoras, miss you buddy. RIP
      return true if distance <= (z[:radius] + radius)
    end
    false
  end

  private

  def read_world
    #TODO: read from external .yml or something
    #TODO: mass and shape for the obstacles
    @boundaries ||= [1000, -1000, 800, -800]#x,-x, y, -y
    @obstacles ||= [{x:0, y:500, radius:20}, {x:300, y:0, radius:20},{x:-900, y:-700, radius:10}]
  end

end

