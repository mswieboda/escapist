require "./box"
require "json"

module Escapist
  abstract class TileObj
    include JSON::Serializable

    getter col : Int32 = 0
    getter row : Int32 = 0

    TileSize = 128
    Size = 96
    Offset = 16 # (TileSize - Size) / 2

    def initialize(*, __pull_for_json_serializable pull : ::JSON::PullParser)
      super
    end

    def initialize(@col = 0, @row = 0)
    end

    def size
      Size
    end

    def x
      col * TileSize + Offset
    end

    def y
      row * TileSize + Offset
    end

    def collision_box
      Box.new(x, y, size, size)
    end

    def draw(window : SF::RenderWindow)
    end

    def jump_to(col, row)
      @col = col
      @row = row
    end
  end
end
