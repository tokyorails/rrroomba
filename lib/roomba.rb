#require 'rubygems'
#require 'serialport'
#include Math

class Roomba
  Dir["#{Rails.root}/lib/roomba/*rb"].each { |file|
  	require file
  }

  include Roomba::API
  include Roomba::Specification

  attr_accessor :serial, :velocity, :degree, :latency, :messages

  SCHEDULE_DAYS = {
    :sunday    => '00000001',
    :monday    => '00000010',
    :tuesday   => '00000100',
    :wednesday => '00001000',
    :thursday  => '00010000',
    :friday    => '00100000',
    :saturday  => '01000000'
  }

  def initialize(port, latency=0.1, baud=115200, serial=nil)
    # baud must be 115200 for communicating with 500 series Roomba and newer (tested with Roomba 770), change to 57600 for 400 series and older
    if serial.nil? # we need to provide our own serial
      setup_default_serial(port, baud)
    else
      @serial = serial
    end
    @messages = []
    @latency = latency
    @position = Position2D.new(serial,latency)
    @sensors = Sensors.new(serial,latency)
    @roomba_driver = RoombaDriver.new(serial,latency)
    @roomba_driver.start
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
    @velocity, @degree = velocity, degree
    @position.drive(velocity,degree)
    start_moving = Time.now
    time_in_seconds = 10 if time_in_seconds > 10
    until (start_moving - Time.now).abs >= time_in_seconds
      # sensors call sleeps the script for 20ms, max read is 50ms, total time between loops about 65ms
      sensors = get_readings(:bumps_and_drops, :wall)
      @messages.push sensors
      break if sensors[:bumps_and_drops][:formatted].to_i(2) > 0
    end
    @position.drive(0,0)
    sensors
  end

  def set_velocity(velocity)
    @position.set_velocity(velocity)
  end

  def set_degree(degree)
    @position.set_degree(degree)
  end

  def calculate_spin_time(velocity, degree)
    # time = wheelbase * PI / 360degrees * degrees / velocity ABS
    # wheelbase might be different for different roombas, consider refactoring
    ((((WHEELBASE * Math::PI) / 360) * degree.abs).to_f / velocity.to_f).abs
  end

  #spinning needs some work
  def calculate_spin_degree(velocity, time)
    ((time.to_f * velocity.to_f) / ((WHEELBASE * Math::PI) / 360)) / 10**10
  end


  def messages
    return @messages.shift(@messages.size)
  end

  def get_readings(*sensors_requested)
    @sensors.get_readings(sensors_requested)
  end

  def report
    sensors = @sensors.report
  
    if sensors[:battery_charge][:text] == 0

    else
      @messages.push sensors
    end

    sensors
  end

  def signed_integer(bytes)
    case bytes.size
    when 1
      return (bytes[0] & ~(1 << 7)) - (bytes[0] & (1 << 7))
    when 2
      sixteenbit = bytes[0] << 8 | bytes[1]
      return (sixteenbit & ~(1 << 15)) - (sixteenbit & (1 << 15))#http://en.wikipedia.org/wiki/Two%27s_complement#Calculating_two.27s_complement
    end
  end

  def motors
    motors(1)
    sleep 2
    motors(2)
    sleep 2
    motors(4)
    sleep 2
    motors(3)
    sleep 2
    motors(7)
    sleep 2
    motors(0)
  end

  def midi(one, two, three, four, five)
    song(2,5, one,64, two,48, three,36, four,30, five,36)
    play(2)
  end

  def demo1
    empire()
    play(0)
    move(1000)
    play(1)
    move(800,140)
    motors(1)
    move(0,90)
    motors(3)
    move(1600,0,400)
    motors(5)
    move(1400,0,-300)
    motors(0)
    move(0,720,300)
    move(0,720,-500)
    play(0)
    move(200,0,40)
    play(1)
    move(200,0,300)
    sleep 1
    spot
    sleep 3
    setup_control
    sleep 1
    dock
    sleep 2
    setup_control
  end

  def empire
    song(0,9, 67,42, 67,42, 67,42, 63,30, 70,12, 67,40, 63,30, 70,12, 67,20)
    song(1,9, 74,42, 74,42, 74,42, 75,30, 70,12, 66,40, 63,30, 70,12, 67,18)
  end

  def wakeup
    @roomba_drive.wakeup
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
    schedule(bytes)
    bytes
  end

  # clears the cleaning schedule
  def clear_schedule
    bytes = [0] * 15
    schedule(bytes)
    bytes
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
  # DATA_REFRESH_RATE. However, Bluetooth serial needs
  # a little extra time between requesting sensor data and
  # fetching. I set @latency to 0.1 or 0.2 in the initializer
  # when using Bluetooth.
  def wait_for_rx
    sleep DATA_REFRESH_RATE + @latency
  end
end
