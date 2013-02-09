# ########
# This class is an specific implementation of a simulation for roomba
# #######
class RoombaSimulation  < RobotSimulation
  def initialize(simulation)
    world = simulation.world
    serial = RoombaSerialSimulation.new
    modify_roomba_internals(simulation)
    real_robot = Roomba.new('simulation', 0, 115200, serial)
    world.spawn(self)

    super(world, serial, real_robot, simulation.formatter)
    self
  end

  def radius
    Roomba::ROOMBA_RADIUS
  end

  private

  #TODO: TOTALLY Hacky. As I do not want to modify Roomba at all if
  #possible, using metaprogramming to modify it from outside here.
  #Eventually Roomba will get this mehods and constants from somewhere
  #else so we can do this correctly.
  def modify_roomba_internals(simulation)
    Roomba.send(:define_method, :current_time) do
      simulation.current_time
    end
    #Same step than the simulation
    Roomba.send(:remove_const, :ROOMBA_DATA_REFRESH_RATE)
    Roomba.const_set(:ROOMBA_DATA_REFRESH_RATE, 0.01)
  end
end


