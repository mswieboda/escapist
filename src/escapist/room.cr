require "./player"
require "./room_doors"
require "./block"

module Escapist
  class Room
    getter tile_columns : Int32
    getter tile_rows : Int32
    getter doors : RoomDoors
    getter blocks : Array(Block)

    delegate entered, to: @doors
    delegate clear_entered, to: @doors

    BorderColor = SF::Color.new(102, 102, 102)
    BorderOutlineThickness = 8
    TileSize = 128
    TileFloorColor = SF::Color.new(6, 6, 6)
    TileGridColor = SF::Color.new(13, 13, 13)
    TileGridOutlineThickness = 2

    def initialize(tile_columns, tile_rows, doors = RoomDoors.new, blocks = Hash(Int32, Hash(Int32, Symbol)).new)
      @tile_columns = tile_columns
      @tile_rows = tile_rows
      @doors = doors
      @blocks = [] of Block

      blocks.each do |col, rows|
        next if col > tile_columns

        rows.each do |row, _block_type|
          next if row > tile_rows

          @blocks << Block.new(col, row)
        end
      end
    end

    def width
      tile_columns * TileSize
    end

    def height
      tile_rows * TileSize
    end

    def update(p : Player | Nil, keys : Keys)
      if player = p
        doors.update(player, keys, width, height)
      end
    end

    def spawn_player(player, room_key)
      doors.spawn_player(player, room_key, width, height)
    end

    def draw(window : SF::RenderWindow, p : Player | Nil)
      # floor
      draw_floor(window)
      draw_tile_grid(window)

      blocks.each(&.draw(window))

      if player = p
        player.draw(window)
      end

      draw_border(window)
      doors.draw(window, width, height)
    end

    def draw_floor(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = TileFloorColor

      window.draw(rect)
    end

    def draw_tile_grid(window)
      tile_columns.times do |col|
        tile_rows.times do |row|
          draw_tile_cell(window, col, row)
        end
      end
    end

    def draw_tile_cell(window, col, row)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(TileSize, TileSize)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = TileGridColor
      rect.outline_thickness = TileGridOutlineThickness
      rect.position = {col * TileSize, row * TileSize}

      window.draw(rect)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = BorderColor
      rect.outline_thickness = BorderOutlineThickness

      window.draw(rect)
    end
  end
end
