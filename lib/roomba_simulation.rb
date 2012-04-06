class RoombaSimulation < Roomba
  def initialize(port="simulation", latency=0, baud=115200)
    @serial = RoombaSerialSimulation.new(port)
    @latency = latency
    sleep 0.2
    api_setup_start
    sleep 0.1
    api_setup_control
  end

  def write(*args)
    @serial.write(*args)
  end
end