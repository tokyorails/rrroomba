require 'console'
require 'world'

##############################
#
#This class is the highest level entity, controls how
#the simulation behaves, contains the world and the robots
#
###############################
class Simulator
  attr_reader :world

  def initialize(world = nil, formatter = nil)
    @world = world || World.new
    @formatter = formatter || Console.new
    @current_time = Time.now
    @running = false
    @world.time = @current_time
  end

  #TODO: should these methods add ! because they modify the simulation ?
  def start
    @running = true
    Thread.abort_on_exception = true
    Thread.new { run }
    self
  end

  def stop
    @running = false
    self
  end

  def running?
    @running
  end

  private

  STEP = 0.01

  def run
    @formatter.info "Simulation started"
    while (@running)
      @world.step(STEP)
      sleep(STEP)
      @current_time += STEP
      @world.time = @current_time
    end
    @formatter.info "Simulation terminated"
  end

end
