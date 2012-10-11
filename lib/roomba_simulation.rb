class RoombaSimulation < Roomba
  def initialize(port="simulation", latency=0, baud=115200)
    @serial = RoombaSerialSimulation.new
    super(port, latency, baud, @serial)
    self
  end

  def render
    @serial.render
  end

  def born_in(*args)
    @serial.born_in(*args)
  end

  def write(*args)
    @serial.write(*args)
  end
end
