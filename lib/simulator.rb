##############################
#
#This class is the highest level entity, controls how
#the simulation behaves, contains the world and the robots
#We already had a simulation model so we call this simulator
#
###############################
class Simulator
  attr_reader :world
  STEP = 0.01

  def initialize(world = nil)
    @world = world || World.new
    @current_time = Time.now
  end

  def add_robot(robot)
    @world.spawn(robot)
  end

  def start
    Thread.abort_on_exception = true
    Thread.new { run }
  end

  def stop
    @wants_to_stop = true
  end

  def running?
    !@wants_to_stop
  end

  private
  def run
    @wants_to_stop = false
    puts "Simulation started"
    while (!@wants_to_stop)
      @world.step(STEP)
      sleep(STEP)
      @current_time += STEP
      @world.time = @current_time
    end
    puts "Simulation terminated"
  end

end
