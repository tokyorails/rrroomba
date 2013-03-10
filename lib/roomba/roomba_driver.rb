class RoombaDriver < Driver
  
  def start
    sleep 0.2
    setup_start
    sleep 0.1
    setup_control
  end

  # wake the Roomba up
  def wakeup
    @serial.rts = 0
    sleep 0.1
    @serial.rts = 1
    sleep 2
    setup_start
    setup_control
  end

  
end
