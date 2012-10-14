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
  
  #makes roomba use our virtual time
  def current_time
    @serial.world.time
  end

  def method_missing(method, *args)
    #we will raise if the method is not there either
    return @serial.send(method, *args) 
  end

end
