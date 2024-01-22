require "./movable_block"

module Escapist
  def self.rotate_vector(vector, angle)
    radians = Math::PI * angle / 180.0
    cos = Math.cos(radians)
    sin = Math.sin(radians)

    {
      x: vector[:x] * cos - vector[:y] * sin,
      y: vector[:x] * sin + vector[:y] * cos
    }
  end

  class LaserBlock < MovableBlock
    @[JSON::Field(ignore: true)]
    getter distance : Float32 | Int32 = 0

    @[JSON::Field(ignore: true)]
    getter rotation_angle : Float32 | Int32 = 0

    Key = "laser"
    LaserBarrelColorFilled = SF::Color.new(51, 51, 51)
    LaserBarrelColor = SF::Color.new(153, 0, 0, 51)
    LaserBarrelOutlineColor = SF::Color.new(153, 0, 0, 153)
    LaserBarrelOutlineThickness = 3
    LaserCenterWidth = 4
    LaserCenterColor = SF::Color.new(153, 0, 0, 153)
    LaserCenterOutlineColor = SF::Color.new(102, 0, 0, 102)
    LaserCenterOutlineThickness = 2
    LaserWidth = 16
    LaserColor = SF::Color.new(102, 0, 0, 102)
    LaserOutlineColor = SF::Color.new(153, 0, 0, 51)
    LaserOutlineThickness = 4

    def initialize(col = 0, row = 0)
      @distance = 0
      @rotation_angle = 0

      super(col, row)
    end

    def self.key
      Key
    end

    def update(room)
      start_point = {x: x + size / 2, y: y + size / 2}
      direction = {x: 0, y: -1}
      direction = Escapist.rotate_vector(direction, rotation_angle)
      distance = cast_ray(start_point, direction, room)
      @distance = distance.to_f32
    end

    def cast_ray(start_point, direction, room)
      x, y = start_point[:x], start_point[:y]
      dx, dy = direction[:x], direction[:y]

      distance = 0

      loop do
        row = (x / room.tile_size).to_i
        col = (y / room.tile_size).to_i

        break if room_found?(row, col, room)

        # no tile_objs, check room bounds
        break if x < 0 || y < 0 || row >= room.rows || col >= room.cols

        distance += 1
        x += dx
        y += dy
      end

      distance
    end

    def room_found?(row, col, room)
      tile_obj_found = nil

      if room.tiles.has_key?(row) && room.tiles[row].has_key?(col)
        tile_obj_found = room.tiles[row][col]
      end

      if tile_obj = tile_obj_found
        if tile_obj != self && tile_obj.collidable?
          return true
        end
      end

      false
    end

    def draw_movable(window : SF::RenderWindow)
      draw_laser_barrel(window)
      draw_laser(window)
    end

    def draw_laser_barrel(window)
      tri_size = size / 8

      # barrel filled, to make opaque
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.rotation = rotation_angle
      tri.fill_color = LaserBarrelColorFilled
      tri.position = {
        x + size / 2,
        y + size / 2,
      }
      window.draw(tri)

      # barrel with laser filling and outline
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.rotation = rotation_angle
      tri.fill_color = LaserBarrelColor
      tri.outline_color = LaserBarrelOutlineColor
      tri.outline_thickness = LaserBarrelOutlineThickness
      tri.position = {
        x + size / 2,
        y + size / 2
      }
      window.draw(tri)
    end

    def draw_laser(window)
      # center laser
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(LaserCenterWidth, distance)
      rect.origin = {
        LaserCenterWidth / 2,
        distance
      }
      rect.rotation = rotation_angle
      rect.fill_color = LaserCenterColor
      rect.outline_color = LaserCenterOutlineColor
      rect.outline_thickness = LaserCenterOutlineThickness
      rect.position = {
        x + size / 2,
        y + size / 2
      }

      window.draw(rect)

      # main laser
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(LaserWidth, distance)
      rect.origin = {
        LaserWidth / 2,
        distance
      }
      rect.rotation = rotation_angle
      rect.fill_color = LaserColor
      rect.outline_color = LaserOutlineColor
      rect.outline_thickness = LaserOutlineThickness
      rect.position = {
        x + size / 2,
        y + size / 2
      }

      window.draw(rect)
    end
  end
end
