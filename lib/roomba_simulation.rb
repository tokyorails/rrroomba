# ########
# This class is an specific implementation of a simulation for roomba
# #######
class RoombaSimulation  < RobotSimulation
  def initialize(simulation)
    world = simulation.world
    bumpers = [ Bumper.new(self, -45, 30, world), Bumper.new(self, 45, 30, world) ]
    serial = RoombaSerialSimulation.new(bumpers)
    modify_roomba_internals(simulation)
    real_robot = Roomba.new('simulation', 0, 115200, serial)
    world.spawn(self)

    super(world, serial, real_robot)
    self
  end

  def radius
    Roomba::Specification::RADIUS
  end

  private

  #TODO: TOTALLY Hacky. Eventually Roomba can get its time from an API so we can hook there.
  def modify_roomba_internals(simulation)
    Roomba.send(:define_method, :current_time) do
      simulation.current_time
    end
  end
end


