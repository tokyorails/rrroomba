class RoombaSerialSimulation
  attr_accessor :simulation, :requested_readings, :readings, :facing, :moving, :velocity, :turning, :degree, :world
  attr_writer :x, :y

  include ByteProcessing
  include Calculations

  # currently the simulation settings are hardcoded in the initializer
  # need to refactor to allow various predefined or even random simulations
  def initialize
    yield self if block_given?

    # Set defaults if not set in the initializer block
    # These defaults match the previously hard-coded values
    @simulation ||= 'simulation'
    @x ||= 0
    @y ||= 0
    @facing ||= 0 #+y, @facing of 90 == +x, @facing of 180 == -y, @facing of 270 == -x

    # The following are not to be set by the user
    @moving = false
    @velocity = 0
    @degree = 0
    @turning = false
    @readings = []
    self
  end

  #components outside here can not see our internal floating point representation
  def x
    @x.round
  end

  def y
    @y.round
  end

  # When the RoombaSimulation class tries to send data to the simulated Roomba
  # this is where that data arrives. Check the first byte to get the opcode
  # if a method exists for handling that opcode, run it; Need to write mock
  # methods for each useful ROI command
  def write(*bytes)
    puts "Bytes Roomba received: #{bytes.inspect}"
    command = bytes.shift
    case command
    when 137
      setup_move(*bytes)
    when 149
      prepare_readings(*bytes)
    end
  end

  def moving?
    return @moving
  end

  def radius
    Roomba::ROOMBA_RADIUS
  end

  def born_in(world)
    @world = world
  end

  def render
    ui = {}
    ui['x'] = x
    ui['y'] = y
    ui['radius'] = radius
    ui['name'] = 'Roomba'
    ui
  end

  def step(step_time)
    if !@turning
      distance = (@velocity * step_time).to_i
      puts "Travelled #{distance}mm"
      @previous_x = @x
      @previous_y = @y
      move_to(@facing, distance)
      puts "N: #@facing, x: #@x, y: #@y"
    else
      @facing = @facing + calculate_spin_degree(@velocity, step_time)
      puts "N:#@facing"
    end
  end

  def step_back
    @x = @previous_x
    @y = @previous_y
  end

  # When the RoombaSimulation requests a byte from
  # the simulated serial port, it gets shifted off the array of available bytes.
  def getbyte
    readings.shift
  end

  def read_timeout=(timeout)
  end

  

  private
  
  # Sets the state of simulated Roomba to moving
  def setup_move(*args)
    # update x, y; check if any obstacle coordinates fall inside roomba's radius;
    # queue sensor readings in some array to simulate TX/RX
    @velocity = signed_integer([args[0], args[1]])
    @moving = (@velocity.abs > 0) ? true : false
    if @moving
      puts "Moving at #{@velocity}mm/s"
    else
      puts "Stopped moving"
    end
    @degree = signed_integer([args[2], args[3]])
    @turning = (@degree.abs == 1) ? true : false
    # Simulation can currently only handle the following (cannot support half-points or curves)
    if @facing.between?(45, 135)
      @facing = 90
    elsif @facing.between?(135, 225)
      @facing = 180
    elsif @facing.between?(225, 315)
      @facing = 270
    else
      @facing = 0
    end
    if @velocity < 0 && @fading != 0
      @facing = 360 - @facing
    end
    return true
  end

  def move_to(direction, distance)
    case direction
    when 0
      @y += distance
    when 90
      @x += distance
    when 180
      @y -= distance
    when 270
      @x -= distance
    end
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
    @readings.push  (@world.collision_with?(self)) ? 1 : 0
  end

end
