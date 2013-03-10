class Sensors
  
  def get_readings(*sensors_requested)
    sensors_requested.collect!{|c| c.to_sym }
    packet_ids = sensors_requested.map{ |sensor| SENSORS[sensor][:packet] }
    bytes = querylist(*packet_ids)
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

    sensors
  end

end
