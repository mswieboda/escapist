require "./block"

module Escapist
  class MovableBlock < BaseBlock
    @[JSON::Field(ignore: true)]
    getter dx : Float32 | Int32 = 0

    @[JSON::Field(ignore: true)]
    getter dy : Float32 | Int32 = 0

    Key = "movable"
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4
    IconMargin = 14
    TileSize = 128 # TODO: share this between tile_obj.cr and everywhere else

    def initialize(col = 0, row = 0)
      @dx = 0
      @dy = 0

      super(Key, col, row)
    end

    def self.key
      Key
    end

    def movable?
      true
    end

    def x
      super + dx
    end

    def y
      super + dy
    end

    def move(dx : Float32 | Int32, dy : Float32 | Int32)
      @dx += dx
      @dy += dy

      if @dx.abs >= TileSize
        @col += @dx.sign
        @dx = @dx + -@dx.sign * TileSize
      end

      if @dy.abs >= TileSize
        @row += @dy.sign
        @dy = @dy + -@dy.sign * TileSize
      end
    end

    def draw(window : SF::RenderWindow)
      super

      draw_icon(window)
    end

    def draw_icon(window)
      tri_size = size / 8

      # top tri
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.fill_color = Color
      tri.position = {
        x + size / 2,
        y + tri_size + IconMargin
      }
      window.draw(tri)

      # left tri
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.fill_color = Color
      tri.rotation = -90
      tri.position = {
        x + tri_size + IconMargin,
        y + size / 2
      }
      window.draw(tri)

      # bottom tri
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.fill_color = Color
      tri.rotation = 180
      tri.position = {
        x + size / 2,
        y + size - tri_size - IconMargin
      }
      window.draw(tri)

      # right tri
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.fill_color = Color
      tri.rotation = 90
      tri.position = {
        x + size - tri_size - IconMargin,
        y + size / 2
      }
      window.draw(tri)
    end
  end
end
