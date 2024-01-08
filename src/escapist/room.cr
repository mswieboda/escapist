require "./player"
# require "./room_doors"
require "./block"
require "json"
require "uuid"

module Escapist
  class Room
    include JSON::Serializable

    alias BlockHash = Hash(Int32, Hash(Int32, String))

    getter id : String
    getter s_cols : Int32
    getter s_rows : Int32

    # @[JSON::Field(ignore: true, emit_null: true)]
    # getter doors : RoomDoors?

    getter blocks : Array(Block)

    # delegate entered, to: @doors
    # delegate clear_entered, to: @doors
    def entered; end
    def clear_entered; end

    TileSize = 128
    SectionTiles = 15

    BorderColor = SF::Color.new(102, 102, 102)
    BorderOutlineThickness = 8
    TileFloorColor = SF::Color.new(6, 6, 6)
    TileGridColor = SF::Color.new(13, 13, 13)
    TileGridOutlineThickness = 2

    def initialize(@s_cols, @s_rows)
      @id = UUID.random.to_s
      @blocks = [] of Block
      # @doors = RoomDoors.new
    end

    def cols
      s_cols * SectionTiles
    end

    def rows
      s_rows * SectionTiles
    end

    def width
      cols * TileSize
    end

    def height
      rows * TileSize
    end

    def display_name
      "#{s_cols}x#{s_rows} b: #{blocks.size}"
    end

    def update(p : Player | Nil, keys : Keys)
      # if player = p
      #   doors.update(player, keys, width, height)
      # end
    end

    def spawn_player(player, room_key)
      # doors.spawn_player(player, room_key, width, height)
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
      # doors.draw(window, width, height)
    end

    def draw_floor(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = TileFloorColor

      window.draw(rect)
    end

    def draw_tile_grid(window)
      cols.times do |col|
        rows.times do |row|
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
