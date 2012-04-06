class RoombaSerialSimulation < Roomba
  attr_accessor :simulation, :requested_readings, :readings, :x, :y, :facing, :boundaries, :obstacles, :moving, :velocity, :turning, :degree, :timestamp
  ROOMBA_RADIUS = 176

  # currently the sumulation settings are hardcoded in the initializer
  # need to refactor to allow various predefined or even random simulations
  def initialize
    yield self if block_given?

    # Set defaults if not set in the initializer block
    # These defaults match the previously hard-coded values
    @simulation ||= 'simulation'
    @x ||= 0
    @y ||= 0
    @facing ||= 0 #+y, @facing of 90 == +x, @facing of 180 == -y, @facing of 270 == -x
    @boundaries ||= [1000, -1000, 800, -800]#x,-x, y, -y
    @obstacles ||= [[0, 500, 20],[300, 0, 20],[-900, -700, 10]]#[x,y,radius]

    # The following are not to be set by the user
    @moving = false
    @velocity = 0
    @degree = 0
    @turning = false
    @readings = []
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
      move(*bytes)
    when 149
      prepare_readings(*bytes)
    end
  end

  # Sets the state of simulated Roomba to moving
  def move(*args)
    # update x, y; check if any obstacle coordinates fall inside roomba's radius;
    # queue sensor readings in some array to simulate TX/RX
    @velocity = signed_integer([args[0], args[1]])
    @moving = (@velocity.abs > 0) ? true : false
    if @moving
      puts "Moving at #{@velocity}mm/s"
    else
      puts "Stopped moving"
    end
    @timestamp = Time.now
    @degree = signed_integer([args[2], args[3]])
    @turning = (@degree.abs == 1) ? true : false
    # Simulation can currently only handle the following (cannot support half-points or curves)
    if @facing > 45 && @facing < 135
      @facing = 90
    elsif @facing >= 135 && @facing < 225
      @facing = 180
    elsif @facing >= 225 && @facing < 315
      @facing = 270
    else
      @facing = 0
    end
    return true
  end

  def moving?
    return @moving
  end

  def obstacle?
    if (@boundaries[0] - @x).abs == ROOMBA_RADIUS || (@boundaries[1] - @x).abs == ROOMBA_RADIUS || (@boundaries[2] - @y).abs == ROOMBA_RADIUS || (@boundaries[3] - @y).abs == ROOMBA_RADIUS
      return true
    end
    @obstacles.each do |z|
      distance = Math.sqrt((@x - z[0])**2 + (@y - z[1])**2) # Pythagoras, miss you buddy. RIP
      #puts "Distance to obstacle: #{distance}mm"
      return true if distance <= (z[2] + ROOMBA_RADIUS)
    end
    false
  end

  def prepare_readings(*args)
    args.each do |request|
      SENSORS.each do |sensor|
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
    start_x = @x
    start_y = @y
    previous_x = 0
    previous_y = 0
    reading = 0 #value of bump_and_drops sensors
    latest_check_time = Time.now
    difference = latest_check_time - @timestamp #difference from last reading
    puts @turning.inspect
    if !@turning
      puts "Time diff: #{difference}"
      distance = (@velocity * difference).to_i
      puts "Travelled #{distance}mm"
      if distance > 0 #driving forward
        1.upto(distance) do |x|
          previous_x = @x
          previous_y = @y
          case @facing
          when 0
            @y = @y+1
          when 90
            @x = @x+1
          when 180
            @y = @y-1
          when 270
            @x = @x-1
          end
          puts "N:#{@facing}, X:#{@x} Y:#{@y}"
          reading = (obstacle?) ? 1 : 0
          break if reading == 1
        end
      else #driving backward, driving blind (no sensors!)
        distance.upto(0) do |x|
          previous_x = @x
          previous_y = @y
          case @facing
          when 0
            @y = @y-1
          when 90
            @x = @x-1
          when 180
            @y = @y+1
          when 270
            @x = @x+1
          end
          puts "N:#{@facing}, X:#{@x} Y:#{@y}"
          blind_reading = (obstacle?) ? 1 : 0
          break if blind_reading == 1
        end
        reading = 0 #always return 0 when driving blind
      end
      if reading == 1 #hit something at that coordinate, impassable, back to previous coordinate (don't share points)
        @x = previous_x
        @y = previous_y
      end
      if start_x != @x || start_y != @y #some coordinate changed
        @timestamp = latest_check_time #enough time accumalated to register movement, record this check in timestamp so we don't accelerate exponentially
      end
    else
      @timestamp = latest_check_time
      @facing = @facing + calculate_spin_degree(@velocity, latest_check_time)
      puts "N:#{@facing}"
    end

    @readings.push(reading)
  end

  # When the RoombaSimulation requests a byte from
  # the simulated serial port, it gets shifted off the array of available bytes.
  def getbyte
    readings.shift
  end

  def read_timeout=(timeout)
  end
end