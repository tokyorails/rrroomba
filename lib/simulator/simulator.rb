require 'console'
require 'world'

##############################
#
#This class is the highest level entity, controls how
#the simulation behaves, contains the world and the robots
#
###############################
class Simulator
  attr_reader :world, :current_time, :formatter

  def initialize(formatter = nil)
    @current_time = Time.now
    @formatter = formatter || Console.new
    @world = World.new
    @running = false
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
      @current_time += STEP
      @world.step(STEP)
      sleep(STEP)
    end
    @formatter.info "Simulation terminated"
  end

end

