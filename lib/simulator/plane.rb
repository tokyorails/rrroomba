#######################################
# This is an infinite 2D plane with infinite mass and infinitely strong
# Objects and robots can collide with it.
# normal is the normal of the plane towards the origin
# distance_to_origin is the distance from the plane to the origin
#######################################
class Plane
  attr_reader :normal, :distance_to_origin

  def initialize(normal, distance_to_origin)
    @normal = normal
    @distance_to_origin = distance_to_origin
  end

  def distance_to(point)
    projected_point = normal.project(point)
    projected_point.x + projected_point.y + distance_to_origin
  end

end

