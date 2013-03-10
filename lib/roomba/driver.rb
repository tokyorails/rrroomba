class Driver

  include Roomba::Api

  def initialize(serial, latency)
    @serial, @latency = serial, latency
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
