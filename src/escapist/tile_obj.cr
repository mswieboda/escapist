require "./box"
require "json"

module Escapist
  abstract class TileObj
    include JSON::Serializable

    use_json_discriminator "type", {block: Block, switch: Switch}

    property type : String = "block"
    getter col : Int32 = 0
    getter row : Int32 = 0

    Key = "to"
    TileSize = 128
    Size = 96
    Offset = 16 # (TileSize - Size) / 2

    def initialize(*, __pull_for_json_serializable pull : ::JSON::PullParser)
      super
    end

    def initialize(@type = "block", @col = 0, @row = 0)
    end

    def self.key
      Key
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

    def area?
      false
    end

    def collidable?
      false
    end

    def collision_box
      Box.new(x, y, size)
    end

    def area_box
      Box.new(x, y, size)
    end

    def area_entered?
      false
    end

    def area_entered
    end

    def area_exited
    end

    def self.cells_near(x, y)
      near_col = (x / TileSize).round.to_i
      near_row = (y / TileSize).round.to_i

      [-1, 0, 1].flat_map do |col_i|
        [-1, 0, 1].map do |row_i|
          {near_col + col_i, near_row + row_i}
        end
      end
    end

    def draw(window : SF::RenderWindow)
    end

    def jump_to(col, row)
      @col = col
      @row = row
    end

    def to_tile_data
      {
        "key" => self.class.key
      }
    end
  end
end
