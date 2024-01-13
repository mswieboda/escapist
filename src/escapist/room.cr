require "./player"
require "./room_doors"
require "./tile_obj"
require "./block"
require "./floor_switch"
require "json"
require "uuid"

module Escapist
  class Room
    include JSON::Serializable

    alias TileRow = Hash(Int32, TileObj)
    alias TileGrid = Hash(Int32, TileRow)

    getter key : String
    getter s_cols : Int32
    getter s_rows : Int32
    getter tiles : TileGrid = TileGrid.new
    getter doors : RoomDoors = RoomDoors.new

    delegate entered, to: @doors
    delegate clear_entered, to: @doors

    TileSize = 128
    SectionTiles = 15

    BorderColor = SF::Color.new(102, 102, 102)
    BorderOutlineThickness = 8
    TileFloorColor = SF::Color.new(6, 6, 6)
    TileGridColor = SF::Color.new(13, 13, 13)
    TileGridOutlineThickness = 2

    def initialize(@s_rows = 1, @s_cols = 1, @key = UUID.random.to_s)
      @tiles = TileGrid.new
      @doors = RoomDoors.new
    end

    def rows
      s_rows * SectionTiles
    end

    def cols
      s_cols * SectionTiles
    end

    def width
      cols * TileSize
    end

    def height
      rows * TileSize
    end

    def display_name
      name = "#{s_cols}x#{s_rows}"
      name += " t: #{tiles.values.flat_map(&.keys.size).sum}"
      name
    end

    def tile_obj?(col, row)
      tiles.has_key?(col) && tiles[col].has_key?(row)
    end

    def remove_tile_obj(col, row)
      return unless tiles.has_key?(col)

      if tiles[col].has_key?(row)
        tiles[col].delete(row)
        tiles.delete(col) if tiles[col].keys.empty?
      end
    end

    def add_tile_obj(place_type : Symbol, col, row)
      tile = case place_type
        when :block
          Block.new(col, row)
        when :floor_switch
          FloorSwitch.new(col, row)
        else
          Block.new(col, row)
        end

      tiles[col] = TileRow.new unless tiles.has_key?(col)
      tiles[col][row] = tile
    end

    def add_door(door : Symbol, room_key, cell_index)
      door_list = case door
        when :top
          doors.top
        when :left
          doors.left
        when :bottom
          doors.bottom
        when :right
          doors.right
        else
          [] of String | Nil # DoorKey via RoomDoors
        end

      section_index = (cell_index / SectionTiles).to_i
      empty_doors = section_index - door_list.size - 2

      if empty_doors > 0
        empty_doors.times do
          door_list << nil
        end
      end

      door_list << room_key
    end

    def update(p : Player | Nil, keys : Keys)
      if player = p
        doors.update(player, keys, width, height)
      end
    end

    def spawn_player(player, room_key)
      doors.spawn_player(player, room_key, width, height)
    end

    def tiles_near(x, y)
      TileObj.cells_near(x, y).compact_map do |(col, row)|
        next unless tiles.has_key?(col) && tiles[col].has_key?(row)
        next unless tile_obj = tiles[col][row]
        tile_obj
      end
    end

    def draw(window : SF::RenderWindow, p : Player | Nil)
      # floor
      draw_floor(window)
      draw_tile_grid(window)

      tiles.values.flat_map(&.values).each(&.draw(window))

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
