class RoombaSimulation < Roomba
  def initialize(port="simulation", latency=0, baud=115200)
    @serial = RoombaSerialSimulation.new do |c|
      c.simulation = port
    end
    super(port, latency, baud, @serial)
  end

  def write(*args)
    @serial.write(*args)
  end

  def render
    ui = {}
    ui['x'] = @serial.x
    ui['y'] = @serial.y
    ui['radius'] = @serial.radius
    ui['name'] = 'Roomba'
    ui
  end
end
