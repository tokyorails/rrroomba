###################
# Our obstacles are circles, but other shapes may come later
###################
class Circle

  attr_reader :position, :radius

  def initialize(position, radius)
    @position, @radius = position, radius
  end

  def distance_to(object)
    if object.class == Circle || object.class.ancestors.include?(RobotSimulation)
       @position.distance_to(object.pos) - ( @radius + object.radius)
    elsif object.class == Position
       @position.distance_to(object) - ( @radius )
    else
      raise "can not calculate distance from Circle to #{object.class}"
    end
  end


end
