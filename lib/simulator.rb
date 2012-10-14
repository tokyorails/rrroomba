##############################
#
#This class is the highest level entity, controls how
#the simulation behaves, contains the world and the robots
#We already had a simulation model so we call this simulator
#
###############################
class Simulator
  attr_reader :world
  attr_writer :stop
  STEP = 0.01

  def initialize(world = nil)
    @world = world || World.new
    @stop = false
    @current_time = Time.now
    Thread.abort_on_exception = true
    Thread.new { run }
  end

  def add_robot(robot)
    @world.spawn(robot)
  end

  
  private
  def run
    puts "Simulation started"
    while (!@stop) 
      @world.step(STEP)
      sleep(STEP)
      @current_time += STEP
      @world.time = @current_time
    end
    puts "Simulation terminated"
  end

end
