########################
# A 2D position
# Positions of objects and robots always represent
# the position if their centers
########################
class Position
  attr_accessor :x, :y

  def initialize(x,y)
    @x, @y = x,y
  end

  def distance_to(position)
    Math.sqrt((@x - position.x)**2 + (@y - position.y)**2) # Pythagoras, miss you buddy. RIP
  end

  def round
    Position.new(@x.round, @y.round)
  end

  def to_s
    "x: #@x, y: #@y"
  end

end
