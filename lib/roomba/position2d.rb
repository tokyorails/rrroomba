###########################
#
#
###########################
class Position2d < Driver

  def drive(velocity,degree)
    set_velocity(velocity)
    set_degree(degree)
    super.drive(@velocity_high, @velocity_low, @radius_high, @radius_low)
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

end
