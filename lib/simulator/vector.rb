################################
# A vector in 2D space
################################
class Vector
  attr_accessor :x, :y

  def initialize(x,y)
    @x, @y = x,y
  end

  def project(position)
    Vector.new(@x * position.x, @y * position.y)
  end

  def length
    Math.sqrt(@x**2 + @y**2)
  end

  def *(scalar)
    @x += @x * scalar
    @y += @y * scalar
  end

  def to_s
    "x: #@x, y: #@y"
  end

end
