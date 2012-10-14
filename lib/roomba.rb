#require 'rubygems'
#require 'serialport'
#include Math

class Roomba
  attr_accessor :serial, :velocity_hex, :velocity_high, :velocity_low, :radius_hex, :radius_high, :radius_low, :latency, :messages

  # Packets requested are sent every 15 ms (0.015), which is the rate Roomba uses to update data. page 17 ROI (2012)
  ROOMBA_DATA_REFRESH_RATE = 0.15 #may need to modify this value for hardware that has any latency issues, increase for more certainty
  ROOMBA_WHEELBASE = 248
  ROOMBA_RADIUS = 176

  # Sensors according to the ROI (2012)
  SENSORS = {
    :bumps_and_drops => { :packet => 7, :bytes => 1, :signed => false, :bits => true },
    :wall => { :packet => 8, :bytes => 1, :signed => false, :bits => true },
    :cliff_left => { :packet => 9, :bytes => 1, :signed => false, :bits => true },
    :cliff_front_left => { :packet => 10, :bytes => 1, :signed => false, :bits => true },
    :cliff_right => { :packet => 12, :bytes => 1, :signed => false, :bits => true },
    :cliff_front_right => { :packet => 11, :bytes => 1, :signed => false, :bits => true },
    :virtual_wall => { :packet => 13, :bytes => 1, :signed => false, :bits => true },
    :wheel_overcurrents => { :packet => 14, :bytes => 1, :signed => false, :bits => true },
    :dirt_detect => { :packet => 15, :bytes => 1, :signed => false },
    :infrared_omni => { :packet => 17, :bytes => 1, :signed => false },
    :infrared_left => { :packet => 52, :bytes => 1, :signed => false },
    :infrared_right => { :packet => 53, :bytes => 1, :signed => false },
    :buttons => { :packet => 18, :bytes => 1, :signed => false, :bits => true },
    :distance => { :packet => 19, :bytes => 2, :signed => true },
    :angle => { :packet => 20, :bytes => 2, :signed => true },
    :charging_state => { :packet => 21, :bytes => 1, :signed => false },
    :voltage => { :packet => 22, :bytes => 2, :signed => false },
    :current => { :packet => 23, :bytes => 2, :signed => true },
    :temperature => { :packet => 24, :bytes => 1, :signed => true },
    :battery_charge => { :packet => 25, :bytes => 2, :signed => false },
    :battery_capacity => { :packet => 26, :bytes => 2, :signed => false },
    :wall_signal => { :packet => 27, :bytes => 2, :signed => false },
    :cliff_left_signal => { :packet => 28, :bytes => 2, :signed => false },
    :cliff_front_left_signal => { :packet => 29, :bytes => 2, :signed => false },
    :cliff_front_right_signal => { :packet => 30, :bytes => 2, :signed => false },
    :cliff_right_signal => { :packet => 31, :bytes => 2, :signed => false },
    :charging_source => { :packet => 34, :bytes => 1, :signed => false, :bits => true },
    :oi_mode => { :packet => 35, :bytes => 1, :signed => false },
    :song_number => { :packet => 36, :bytes => 1, :signed => false },
    :song_playing => { :packet => 37, :bytes => 1, :signed => false, :bits => true },
    :number_of_stream_packets => { :packet => 38, :bytes => 1, :signed => false },
    :requested_velocity => { :packet => 39, :bytes => 2, :signed => true },
    :requested_radius => { :packet => 40, :bytes => 2, :signed => true },
    :requested_right_velocity => { :packet => 41, :bytes => 2, :signed => true },
    :requested_left_velocity => { :packet => 42, :bytes => 2, :signed => true },
    :right_encoder_counts => { :packet => 43, :bytes => 2, :signed => false },
    :left_encoder_counts => { :packet => 44, :bytes => 2, :signed => false },
    :light_bumper => { :packet => 45, :bytes => 1, :signed => false, :bits => true },
    :light_bump_left_signal => { :packet => 46, :bytes => 2, :signed => false },
    :light_bump_front_left_signal => { :packet => 47, :bytes => 2, :signed => false },
    :light_bump_center_left_signal => { :packet => 48, :bytes => 2, :signed => false },
    :light_bump_center_right_signal => { :packet => 49, :bytes => 2, :signed => false },
    :light_bump_front_right_signal => { :packet => 50, :bytes => 2, :signed => false },
    :light_bump_right_signal => { :packet => 51, :bytes => 2, :signed => false },
    :left_motor_current => { :packet => 54, :bytes => 2, :signed => true },
    :right_motor_current => { :packet => 55, :bytes => 2, :signed => true },
    :main_brush_motor_current => { :packet => 56, :bytes => 2, :signed => true },
    :side_brush_motor_current => { :packet => 57, :bytes => 2, :signed => true },
    :statis => { :packet => 58, :bytes => 1, :signed => false, :bits => true },
  }

  SCHEDULE_DAYS = {
    :sunday    => '00000001',
    :monday    => '00000010',
    :tuesday   => '00000100',
    :wednesday => '00001000',
    :thursday  => '00010000',
    :friday    => '00100000',
    :saturday  => '01000000'
  }

  include ByteProcessing
  include Calculations

  def initialize(port, latency=0.1, baud=115200, serial=nil)
    # baud must be 115200 for communicating with 500 series Roomba and newer (tested with Roomba 770), change to 57600 for 400 series and older
    if serial.nil? # we need to provide our own serial
      setup_default_serial(port, baud)
    else
      @serial = serial
    end
    @messages = []
    @latency = latency
    sleep 0.2
    api_setup_start
    sleep 0.1
    api_setup_control
    self
  end

  def setup_default_serial(port, baud)
    if port[/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\:[0-9]{1,5}/]
      require 'socket'
      @serial = TCPSocket.open(port.split(":")[0], port.split(":")[1])
      def @serial.read_timeout=(value) end
      def @serial.rts=(value) end
    else
      @serial = SerialPort.new(port, baud, 8, 1, SerialPort::NONE)
    end
  end
  private :setup_default_serial

  # distance is in mm
  # velocity is in mm/s (-500 to 500)
  # set distance = 0 and degree > 0 to spin roomba in place
  def move(distance, degree=0, velocity=200)
    distance = distance.to_i.abs #distance can never be negative
    if distance == 0 #not moving, just spinning on axis
      # time = wheelbase * PI / 360degrees * degrees / velocity ABS
      # wheelbase might be different for different roombas
      time_in_seconds = calculate_spin_time(velocity, degree)
      # now that we know how long to spin, set degree to 1 so it will spin roomba instead of put it on an arc
      degree = 1
    else
      time_in_seconds = (distance.to_f / velocity.to_f).abs
    end
    set_velocity(velocity)
    set_degree(degree)
    api_drive(@velocity_high, @velocity_low, @radius_high, @radius_low)
    time_in_seconds = 10 if time_in_seconds > 10
    start_moving = current_time
    until (start_moving - current_time).abs >= time_in_seconds
      # sensors call sleeps the script for 20ms, max read is 50ms, total time between loops about 65ms
      sensors = get_readings(:bumps_and_drops, :wall)
      @messages.push sensors
      break if sensors[:bumps_and_drops][:formatted].to_i(2) > 0
    end
    api_drive(0,0,0,0)
    sensors
  end

  def current_time
    Time.now
  end

  def set_degree(degree)
    if degree == 0
      mm = 32768
    elsif degree.abs == 1
      mm = 1 * (degree <=> 0)
    else
      #Roomba will drive on an arc
      degree = -degree #I want right to be positive and left to be negative :)
      degree = (180 - degree.abs) * (degree <=> 0)
      mm = (1.0 / (180.0 / 2000.0)) * degree.to_f
    end

    @radius_hex = "%04X" % mm.to_i
    @radius_high = @radius_hex[0..1].to_i(16)#high byte
    @radius_low = @radius_hex[2..3].to_i(16)#low byte
  end

  def set_velocity(velocity)
    if velocity.abs > 500
      velocity = 500 * (velocity <=> 0)#don't forget the sign
    end
    @velocity_hex = ("%04X" % velocity).sub("..","F")[-4,4]#have to remove the leading .. when a two's complement negative is converted to hex
    @velocity_high = @velocity_hex[0..1].to_i(16)#high byte
    @velocity_low = @velocity_hex[2..3].to_i(16)#low byte
  end

  def messages
    return @messages.shift(@messages.size)
  end

  # quick report of basic info, should break this out into individual method calls
  def report
    sensors = get_readings(:temperature, :oi_mode, :charging_source, :battery_charge, :battery_capacity, :current)
    sensors[:temperature][:text] = sensors[:temperature][:formatted].to_s + " Celsius"
    sensors[:battery_charge][:text] = sensors[:battery_charge][:formatted]
    sensors[:battery_capacity][:text] = sensors[:battery_capacity][:formatted]
    sensors[:current][:text] = sensors[:current][:formatted].to_s + " mA"

    sensors[:oi_mode][:text] = case sensors[:oi_mode][:formatted]
    when 0
      "off"
    when 1
      "passive mode"
    when 2
      "safe mode"
    when 3
      "full mode"
    end

    sensors[:charging_source][:text] = case sensors[:charging_source][:raw]
    when 1
      "charging"
    when 2
      "docked"
    when 3
      "docked+"
    else
      "undocked"
    end

    if sensors[:battery_charge][:text] == 0

    else
      @messages.push sensors
    end
    sensors
  end

  def get_readings(*sensors_requested)
    sensors_requested.collect!{|c| c.to_sym }
    packet_ids = sensors_requested.map{ |sensor| SENSORS[sensor][:packet] }
    bytes = api_querylist(*packet_ids)
    readings = {}
    readings[:time] = Time.now.to_i
    sensors_requested.each do |sensor|
      readings[sensor] = {:raw => nil, :formatted => []}
      readings[sensor][:raw] = bytes.shift(SENSORS[sensor][:bytes])
      readings[sensor][:formatted] = set_readings(sensor, readings[sensor][:raw])
      puts "Sensors: #{readings[sensor].inspect}"
    end
    readings #return hash of readings
  end

  def set_readings(sensor, readings)
    readings[0] = 0 if readings[0].nil?
    if SENSORS[sensor][:bytes] > 1
      readings[1] = 0 if readings[1].nil?
    end
    if SENSORS[sensor][:bits] #return a string representation of the bits
      return readings.first.to_s(2)
    elsif !SENSORS[sensor][:signed] && SENSORS[sensor][:bytes] == 1 #return an unsigned integer
      return readings.first
    elsif SENSORS[sensor][:signed] && SENSORS[sensor][:bytes] == 1 #return a signed integer
      return signed_integer(readings)
    elsif !SENSORS[sensor][:signed] && SENSORS[sensor][:bytes] == 2 #return an unsigned 2 byte integer
      return readings[0] << 8 | readings[1]
    else SENSORS[sensor][:signed] && SENSORS[sensor][:bytes] == 2 #return a signed 2 byte integer, twos complement
      return signed_integer(readings)
    end
  end

  def motors
    api_motors(1)
    sleep 2
    api_motors(2)
    sleep 2
    api_motors(4)
    sleep 2
    api_motors(3)
    sleep 2
    api_motors(7)
    sleep 2
    api_motors(0)
  end

  def midi(one, two, three, four, five)
    api_song(2,5, one,64, two,48, three,36, four,30, five,36)
    api_play(2)
  end

  def demo1
    empire()
    api_play(0)
    move(1000)
    api_play(1)
    move(800,140)
    api_motors(1)
    move(0,90)
    api_motors(3)
    move(1600,0,400)
    api_motors(5)
    move(1400,0,-300)
    api_motors(0)
    move(0,720,300)
    move(0,720,-500)
    api_play(0)
    move(200,0,40)
    api_play(1)
    move(200,0,300)
    sleep 1
    api_spot
    sleep 3
    api_setup_control
    sleep 1
    api_dock
    sleep 2
    api_setup_control
  end

  def empire
    api_song(0,9, 67,42, 67,42, 67,42, 63,30, 70,12, 67,40, 63,30, 70,12, 67,20)
    api_song(1,9, 74,42, 74,42, 74,42, 75,30, 70,12, 66,40, 63,30, 70,12, 67,18)
  end

  # wake the Roomba up
  def wakeup
    @serial.rts = 0
    sleep 0.1
    @serial.rts = 1
    sleep 2
    api_setup_start
    api_setup_control
  end

  # sets the cleaning schedule
  # expects a hash like: {:monday => '10:30', :tuesday => '14:00', ...}
  def schedule_cleaning(days={})
    return if days.empty?
    days.delete_if {|key, value| !(SCHEDULE_DAYS.has_key? key.to_sym) }
    bytes = []
    bytes << days.keys.map{|d| SCHEDULE_DAYS[d.to_sym]}.inject(0){|res,b| res | b.to_i(2)} # bitwise OR the days to make the first byte of the schedule command
    SCHEDULE_DAYS.keys.each do |day| # ruby 1.9 keeps the hash order so it should be ok but it might not work as expected in 1.8
      time = days[day] || days[day.to_s]  # accept both strings and symbols as keys
      bytes.concat(time && !time.empty? ? time.split(':').map(&:to_i) : [0,0])
    end
    api_schedule(bytes)
    bytes
  end

  # clears the cleaning schedule
  def clear_schedule
    bytes = [0] * 15
    api_schedule(bytes)
    bytes
  end



  # ALL OF THE FOLLOWING METHODS will become private in a future release
  # left as public until they have been sufficiently abstracted at a higher level.
  # Refer to the ROI for accurate documentation except where noted specifically in the comments here

  # Must call this first to start the serial command interface, called in initializer
  def api_setup_start
    write(128)
  end

  # Roomba defaults to 115200
  def api_setup_baud(baud_code)
    # code (convert to binary) = rate
    # 5 = 9600
    # 6 = 14400
    # 7 = 19200
    # 10 = 57600
    # 11 = 115200
    write(129, baud_code)
  end

  # Enables user control of Roomba, puts SCI in safe mode
  def api_setup_control
    write(130)
  end

  # Default mode when SCI is accessed.
  def api_setup_safemode
    write(131)
  end

  # Unrestricted control of Roomba with all safety features
  # turned off. Tread lightly.
  def api_setup_fullmode
    write(132)
  end

  # Puts the Roomba to sleep and in passive mode
  def api_power
    write(133)
  end

  # Starts a spot cleaning cycle.
  def api_spot
    write(134)
  end

  # Starts a normal cleaning cycle.
  def api_clean
    write(135)
  end

  # Starts a maximum cleaning cycle.
  def api_max
    write(136)
  end

  # schedules cleaning
  def api_schedule(bytes)
    write(167, *bytes)
  end

  # Sets Roomba's clock.
  # Day: [Sunday = 0, Monday = 1, Tuesday = 2, Wednesday = 3
  # Thursday = 4, Friday = 5, Saturday = 6]
  # Hour: 24-hour format (integer 0 - 23)
  # Minute: integer 0 - 59
  def api_day_time(day, hour, minute)
    write(168, day, hour, minute)
  end

  # Controls Roomba's drive wheels.
  # The command takes four data bytes, which are interpreted
  # as two 16 bit signed values using twos-complement. The
  # first two bytes specify the average velocity of the drive
  # wheels in millimeters per second (mm/s), with the high byte
  # sent first. The next two bytes specify the radius, in
  # millimeters, at which Roomba should turn. The longer radii
  # make Roomba drive straighter; shorter radii make it turn more.
  # A Drive command with a positive velocity and a positive
  # radius will make Roomba drive forward while turning toward
  # the left. A negative radius will make it turn toward the
  # right. Special cases for the radius make Roomba turn in
  # place or drive straight, as specified below.
  # Serial sequence: [137] [Velocity high byte] [Velocity low byte] [Radius high byte] [Radius low byte]
  # Drive data bytes 1 and 2: Velocity (-500 – 500 mm/s)
  # Drive data bytes 3 and 4: Radius (-2000 – 2000 mm)
  # Special cases: Straight = 32768 = hex 8000
  # Turn in place clockwise = -1 Turn in place counter-clockwise = 1
  #
  # To drive in reverse at a velocity of -200 mm/s while turning at a radius of 500mm, send the following serial byte sequence:
  # [137] [255] [56] [1] [244]
  # To drive forward at a velocity of 200 mm/s while turning at a radius of 500mm, send the following serial byte sequence:
  # [137] [1] [56] [1] [244]
  #
  # api_drive(255, 0, 0, 0) //go backward, fast!
  # api_drive(127, 127, 0, 0) //go backward, fast!
  # api_drive(0, 255, 0, 0) //go forward, fast!
  # api_drive(10, 10, 0, 0) //go forward, slow
  # api_drive(0, 0, 0, 0) // stop!
  #
  def api_drive(velocity_high, velocity_low, radius_high, radius_low)
    write(137, velocity_high, velocity_low, radius_high, radius_low)
  end

  # Controls Roomba's cleaning motors
  # Pass a single byte (8 bits) representing on and off states
  # for up to 8 different motors. Roomba actually only
  # reads bits 0,1, and 2 for the "side brush", "vacuum", and
  # "main brush" respectively. UPDATE: Newer Roombas also read
  # bits 3,4 for determining brush direction (spin clockwise / counter)
  # To turn on the only the vacuum motor send [138] [2] which
  # is 00000010, send [138] [7] to turn on all: 00000111
  def api_motors(byte)
    write(138, byte)
  end

  # Controls Roomba’s LEDs. The state of each of the spot,
  # clean, max, and dirt detect LEDs is specified by one bit
  # in the first data byte. The color of the status LED is
  # specified by two bits in the first data byte. The power
  # LED is specified by two data bytes, one for the color
  # and one for the intensity.
  # FIRST BYTE:
  # bit 0 = "dirt detect led", bit 1 = "max led"
  # bit 2 = "clean led", bit 3 = "spot led"
  # bit 4+5 = "status led", bit 7+8 unused
  # "status led" is a bicolor led. 00 = off, 01 = red
  # 10 = green, 11 = amber
  # To turn on all LEDs except "max" and make "status" amber
  # color send [61] which is 00111101
  # SECOND BYTE: (power led color, 8-bit resolution)
  # 0 - 255, 0 = green, 255 = red. Intermediate values allowed.
  # THIRD BYTE: (power led intensity)
  # 0 - 255, 0 = off, 255 = "dratw". Intermediate values allowed.
  def api_leds(leds, power_color, power_intensity)
    write(139, leds, power_color, power_intensity)
  end

  # SEE SCI SPECIFICATION
  # api_song(0, 4, 62, 12, 66, 12, 69, 12, 74, 36) #makes a song with 4 notes in slot 0
  # api_play(0) #plays the song we just made
  # Examples worth trying:
  # api_song(0,9, 67,42, 67,42, 67,42, 63,30, 70,12, 67,40, 63,30, 70,12, 67,20)
  # api_song(1,9, 74,42, 74,42, 74,42, 75,30, 70,12, 66,40, 63,30, 70,12, 67,18)
  def api_song(*bytes)
    write(140, *bytes)
  end

  # Plays one of 16 songs, as specified by an earlier Song
  # command. If the requested song has not been specified
  # yet, the Play command does nothing.
  def api_play(song)
    write(141, song)
  end

  # Requests the ROI to send a packet of sensor data bytes.
  # The user can select one of four different sensor packets.
  # The packet code 0-3 returns different depending on the sensor.
  # Specifies which of the four sensor data packets should be sent
  # back by the SCI. A value of 0 specifies a packet with all of
  # the sensor data. Values of 1 through 3 specify specific
  # subsets of the sensor data. SEE ROI SPECIFICATIONS FOR
  # LIST OF SENSORS AND SUBSETS.
  def api_sensors(packet_code)
    write(142, packet_code)
    wait_for_rx
    read
  end

  def api_querylist(*bytes)
    write(149, bytes.length, *bytes)
    wait_for_rx
    read
  end

  def api_stream(*bytes)
    write(148, bytes.length, *bytes)
  end

  def api_stream_control(on_off)
    write(150, on_off)
  end

  # Roomba must be in clean, spot, or max mode to activate.
  # Will immediately attempt to dock if docking beams
  # from the home base are detected.
  def api_dock
    write(143)
  end

  private
  # Change all the arguments to single bytes before writing
  def write(*args)
    args.each do |a|
      @serial.write a.chr
    end
  end

  def read(timeout=50)
    @serial.read_timeout= timeout
    bytes = []
    until (x = @serial.getbyte).nil? #read as single bytes
      bytes.push(x)
    end
    bytes
  end

  # Direct serial cable works fine in my setup with just the
  # ROOMBA_DATA_REFRESH_RATE. However, Bluetooth serial needs
  # a little extra time between requesting sensor data and
  # fetching. I set @latency to 0.1 or 0.2 in the initializer
  # when using Bluetooth.
  def wait_for_rx
    sleep ROOMBA_DATA_REFRESH_RATE + @latency
  end
end
