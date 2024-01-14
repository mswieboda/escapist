require "./box"
require "json"

module Escapist
  abstract class TileObj
    include JSON::Serializable

    use_json_discriminator "type", {block: BaseBlock, switch: Switch}

    property type : String = "block"
    getter col : Int32 = 0
    getter row : Int32 = 0

    Key = "to"
    TileSize = 128
    DrawSize = 96

    def initialize(*, __pull_for_json_serializable pull : ::JSON::PullParser)
      super
    end

    def initialize(@type = "block", @col = 0, @row = 0)
    end

    def self.key
      Key
    end

    def size
      TileSize
    end

    def self.draw_size
      DrawSize
    end

    def draw_size
      self.class.draw_size
    end

    def draw_offset
      (size - draw_size) / 2
    end

    def x
      col * TileSize
    end

    def y
      row * TileSize
    end

    def area?
      false
    end

    def collidable?
      false
    end

    def movable?
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

    def move(dx : Float32 | Int32, dy : Float32 | Int32)
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
  end
end
