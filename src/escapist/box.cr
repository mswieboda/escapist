module Escapist
  class Box
    property x : Int32 | Float32
    property y : Int32 | Float32
    property width : Int32 | Float32
    property height : Int32 | Float32

    def initialize(@x, @y, @width, height = nil)
      @height = height ? height : @width
    end

    def collision?(other : Box)
      # calc right and bottom edges
      right = x + width
      other_right = other.x + other.width
      bottom = y + height
      other_bottom = other.y + other.height

      # check if boxes overlap on both axes
      (x < other_right && right > other.x) &&
        (y < other_bottom && bottom > other.y)
    end
  end
end
