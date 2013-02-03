# ########
# This class is an specific implementation of a simulation for roomba
# #######
class RoombaSimulation  < RobotSimulation
  def initialize(simulation)
    world = simulation.world
    serial = RoombaSerialSimulation.new
    real_robot = Roomba.new('simulation', 0, 115200, serial)
    world.spawn(self)

    super(world, serial, real_robot)
    self
  end

  def radius
    Roomba::ROOMBA_RADIUS
  end

end


