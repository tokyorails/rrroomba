# #####################
# This class is an abstract interface for simulated robots
# it can not be used directly
# Child classes need to call the initializer with a serial and a the
# class which drives the robot.
# They need also to implement radius so we know its geometry
# ###################
class RobotSimulation
  attr_reader :facing

  def initialize(world, serial, real_robot)
    raise "A virtual robot needs virtual hardware" if serial.nil?
    raise "A virtual robot needs a real robot implementation" if real_robot.nil?
    raise "A virtual robot needs a simulation" if world.nil?
    @serial = serial
    @real_robot = real_robot
    @world = world

    yield self if block_given?

    # Set defaults if not set in the initializer block
    # These defaults match the previously hard-coded values
    @x ||= 0
    @y ||= 0
    @facing ||= 0 #+y, @facing of 90 == +x, @facing of 180 == -y, @facing of 270 == -x
    @previous_x = @previous_y = 0
    #TODO: formatter has to be a singleton everyone can use
    @formatter = Console.new
  end

  def radius
    100  #default radius, this method should be overloaded by every robot
  end

  def step(step_time)
    @previous_x = @x
    @previous_y = @y
    @facing = @facing + @serial.calculate_rotation(step_time)
    distance = @serial.calculate_distance(step_time)
    move_to(@facing, distance)
    @formatter.debug "N: #@facing, x: #@x, y: #@y"
  end

  #TODO: this is fugly, should be a better way to stop on obstacles
  def step_back
    @x = @previous_x
    @y = @previous_y
  end

  def render
    ui = {}
    ui['x'] = x
    ui['y'] = y
    ui['radius'] = radius
    ui['name'] = 'Roomba'
    ui
  end

  def x
    @x.round
  end

  def y
    @y.round
  end

  #TODO: move this to a class and pass it in a constructor to the real
  #robot
  #makes roomba use our virtual time
  def current_time
    @serial.world.time
  end

  #TODO: this method could have a better name
  def got_collitions?
    @world.collision.with?(@virtual_roomba)
  end

  private

  def move_to(direction, distance)
    case direction
    when 0
      @y += distance
    when 90
      @x += distance
    when 180
      @y -= distance
    when 270
      @x -= distance
    end
  end

  def method_missing(method, *args)
    #we will raise if the method is not there either
    return @real_robot.send(method, *args)
  end

end
