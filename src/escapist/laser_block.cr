require "./movable_block"

module Escapist
  class LaserBlock < MovableBlock
    @[JSON::Field(ignore: true)]
    getter distance : Float32 | Int32 = 0

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

      super(col, row)
    end

    def self.key
      Key
    end

    def update(_room, collidables)
      laser_x = x + size / 2 - LaserWidth / 2

      # find closest collidable in the -y direction or wall
      # TODO: later will need room for width/height if laser is rotated
      y_edges = collidables.compact_map do |tile_obj|
        next if tile_obj.x + tile_obj.size < laser_x
        next if tile_obj.x > laser_x + LaserWidth

        tile_edge = tile_obj.y + tile_obj.size

        y > tile_edge ? tile_edge : nil
      end

      # start at room edge, depending on direction TBD using `_room`
      y_edge = 0

      unless y_edges.empty?
        y_edges << y_edge
        y_edge = y_edges.max
      end

      laser_origin_y = y + size / 2
      @distance = (laser_origin_y - y_edge).to_f32
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
      tri.fill_color = LaserBarrelColorFilled
      tri.position = {
        x + size / 2,
        y + size / 2,
      }
      window.draw(tri)

      # barrel with laser filling and outline
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
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
