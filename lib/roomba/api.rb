module Roomba::Api
  # ALL OF THE FOLLOWING METHODS will become private in a future release
  # left as public until they have been sufficiently abstracted at a higher level.
  # Refer to the ROI for accurate documentation except where noted specifically in the comments here

  # Must call this first to start the serial command interface, called in initializer
  def setup_start
    write(128)
  end

  # Roomba defaults to 115200
  def setup_baud(baud_code)
    # code (convert to binary) = rate
    # 5 = 9600
    # 6 = 14400
    # 7 = 19200
    # 10 = 57600
    # 11 = 115200
    write(129, baud_code)
  end

  # Enables user control of Roomba, puts SCI in safe mode
  def setup_control
    write(130)
  end

  # Default mode when SCI is accessed.
  def setup_safemode
    write(131)
  end

  # Unrestricted control of Roomba with all safety features
  # turned off. Tread lightly.
  def setup_fullmode
    write(132)
  end

  # Puts the Roomba to sleep and in passive mode
  def power
    write(133)
  end

  # Starts a spot cleaning cycle.
  def spot
    write(134)
  end

  # Starts a normal cleaning cycle.
  def clean
    write(135)
  end

  # Starts a maximum cleaning cycle.
  def max
    write(136)
  end

  # schedules cleaning
  def schedule(bytes)
    write(167, *bytes)
  end

  # Sets Roomba's clock.
  # Day: [Sunday = 0, Monday = 1, Tuesday = 2, Wednesday = 3
  # Thursday = 4, Friday = 5, Saturday = 6]
  # Hour: 24-hour format (integer 0 - 23)
  # Minute: integer 0 - 59
  def day_time(day, hour, minute)
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
  # drive(255, 0, 0, 0) //go backward, fast!
  # drive(127, 127, 0, 0) //go backward, fast!
  # drive(0, 255, 0, 0) //go forward, fast!
  # drive(10, 10, 0, 0) //go forward, slow
  # drive(0, 0, 0, 0) // stop!
  #
  def drive(velocity_high, velocity_low, radius_high, radius_low)
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
  def motors(byte)
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
  def leds(leds, power_color, power_intensity)
    write(139, leds, power_color, power_intensity)
  end

  # SEE SCI SPECIFICATION
  # song(0, 4, 62, 12, 66, 12, 69, 12, 74, 36) #makes a song with 4 notes in slot 0
  # play(0) #plays the song we just made
  # Examples worth trying:
  # song(0,9, 67,42, 67,42, 67,42, 63,30, 70,12, 67,40, 63,30, 70,12, 67,20)
  # song(1,9, 74,42, 74,42, 74,42, 75,30, 70,12, 66,40, 63,30, 70,12, 67,18)
  def song(*bytes)
    write(140, *bytes)
  end

  # Plays one of 16 songs, as specified by an earlier Song
  # command. If the requested song has not been specified
  # yet, the Play command does nothing.
  def play(song)
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
  def sensors(packet_code)
    write(142, packet_code)
    wait_for_rx
    read
  end

  def querylist(*bytes)
    write(149, bytes.length, *bytes)
    wait_for_rx
    read
  end

  def stream(*bytes)
    write(148, bytes.length, *bytes)
  end

  def stream_control(on_off)
    write(150, on_off)
  end

  # Roomba must be in clean, spot, or max mode to activate.
  # Will immediately attempt to dock if docking beams
  # from the home base are detected.
  def dock
    write(143)
  end
end