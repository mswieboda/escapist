require "./player"
require "./room_doors"

module Escapist
  class Room
    getter tile_columns : Int32
    getter tile_rows : Int32
    getter doors : RoomDoors

    OutlineThickness = 8
    TileSize = 128

    def initialize(tile_columns, tile_rows, doors = RoomDoors.new)
      @tile_columns = tile_columns
      @tile_rows = tile_rows
      @doors = doors
    end

    def width
      tile_columns * TileSize
    end

    def height
      tile_rows * TileSize
    end

    def update(p : Player, keys : Keys)
      if player = p
        doors.update(player, keys, width, height)
      end
    end

    def draw(window : SF::RenderWindow, p : Player | Nil)
      if player = p
        player.draw(window)
      end

      draw_border(window)
      doors.draw(window, width, height)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(99, 99, 99)
      rect.outline_thickness = OutlineThickness

      window.draw(rect)
    end
  end
end
