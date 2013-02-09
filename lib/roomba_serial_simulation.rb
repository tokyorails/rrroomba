class RoombaSerialSimulation

  include ByteProcessing
  include Calculations

  # currently the simulation settings are hardcoded in the initializer
  # need to refactor to allow various predefined or even random simulations
  def initialize(virtual_roomba = nil, formatter = nil)
    # The following are not to be set by the user
    @moving = false
    @velocity = 0
    @degree = 0
    @turning = false
    @readings = []
    @formatter = formatter || Console.new
    @virtual_roomba = virtual_roomba # TODO: only used to check collitions, may go to bumper in the future.
    @waiting_bytes = 0
    @command_bytes = []
    self
  end

  # When the RoombaSimulation class tries to send data to the simulated Roomba
  # this is where that data arrives.
  # Roomba will write one byte at a time here
  # we need to take all the bytes and reconstruct the original order
  # This method will be highly simplify when we abstract from the byte
  # protocoll of Roomba to a more general interface.
  # Need to write mock methods for each useful ROI command

  def write(*bytes)
    byte = bytes.first.ord
    if @waiting_bytes == 0
      command = byte
      @command_bytes = [command]
      @waiting_bytes = bytes_needed_per_command(command)
    else
      @command_bytes.push byte
      @waiting_bytes -= 1
      if @waiting_bytes == 0
        dispatch_command
      end
    end
  end

  def moving?
    return @moving
  end

  def calculate_rotation(step_time)
    if @turning
      calculate_spin_degree(@velocity, step_time)
    else
      0
    end
  end

  def calculate_distance(step_time)
    if @turning
      0
    else
      @velocity * step_time
    end
  end


  # When the RoombaSimulation requests a byte from
  # the simulated serial port, it gets shifted off the array of available bytes.
  def getbyte
    @readings.shift
  end

  def read_timeout=(timeout)
  end


  private

  def dispatch_command
    command = @command_bytes.shift
    case command
    when 137
      setup_move(@command_bytes)
    when 149
      prepare_readings(@command_bytes)
    when 128,130
      @formatter.info "Roomba API ready to receive commands"
    else
      @formatter.debug "Command not implemented #{command}"
    end
  end

  def bytes_needed_per_command(command)
    bytes_per_command = { 137 => 4, 128 => 0, 130 => 0, 149 => 3 }
    bytes_per_command[command] || 0
  end
  
  # Sets the state of simulated Roomba to moving
  def setup_move(args)
    # update x, y; check if any obstacle coordinates fall inside roomba's radius;
    # queue sensor readings in some array to simulate TX/RX
    @velocity = signed_integer([args[0], args[1]])
    @moving = (@velocity.abs > 0) ? true : false
    if @moving
      @formatter.debug "Moving at #{@velocity}mm/s"
    else
      @formatter.debug "Stopped moving"
    end
    @degree = signed_integer([args[2], args[3]])
    @turning = (@degree.abs == 1) ? true : false

    return true
  end

  def prepare_readings(*args)
    args.each do |request|
      Roomba::SENSORS.each do |sensor|
        if sensor[1][:packet] == request
          if respond_to? "prepare_reading_#{request}".to_sym
            send("prepare_reading_#{request}".to_sym)
          else
            1.upto(sensor[1][:bytes]) { @readings.push(0) }
          end
        end
      end
    end
  end

  # Requested the bump and drops sensor.
  # Most of this code should exist in a method that simply tracks
  # Roomba's state, so that other sensors that also check Roomba's immediate
  # environment can leverage the same current X,Y coordinates
  def prepare_reading_7
    # TODO: distinguish collisions with bumpers and not bumpers
    if @virtual_roomba.got_collisions?
      @readings.push 1
    else
      @readings.push 0
    end
  end

end
