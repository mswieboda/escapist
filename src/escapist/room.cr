require "./player"
require "./room_doors"
require "./tile_obj"
require "./block"
require "./movable_block"
require "./laser_block"
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

    def self.tile_size
      TileSize
    end

    def tile_size
      self.class.tile_size
    end

    def rows
      s_rows * SectionTiles
    end

    def cols
      s_cols * SectionTiles
    end

    def width
      cols * tile_size
    end

    def height
      rows * tile_size
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

    def move_tile_obj(col, row, new_col, new_row)
      if tiles[col].has_key?(row)
        if tile_obj = tiles[col].delete(row)
          tiles.delete(col) if tiles[col].keys.empty?

          tiles[new_col] = TileRow.new unless tiles.has_key?(new_col)
          tiles[new_col][new_row] = tile_obj
        end
      end
    end

    def add_tile_obj(place_type : Symbol, col, row)
      tile = case place_type
      when :block
        Block.new(col, row)
      when :movable_block
        MovableBlock.new(col, row)
      when :laser_block
        LaserBlock.new(col, row)
      when :floor_switch
        FloorSwitch.new(col, row)
      else
        Block.new(col, row)
      end

      tiles[col] = TileRow.new unless tiles.has_key?(col)
      tiles[col][row] = tile
    end

    def add_door(door : Symbol, room_key, section_index)
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

      # TODO: until figuring out which one to spawn to is fixed
      return if door_list.includes?(room_key)

      empty_doors = -door_list.size + 1 + section_index

      if empty_doors > 0
        empty_doors.times do
          door_list << nil
        end
      end

      door_list[section_index] = room_key
    end

    def update(frame_time, keys : Keys, p : Player | Nil)
      if player = p
        doors.update(player, keys, width, height)
      end

      update_tiles
      update_laser_blocks(frame_time)
    end

    def update_tiles
      tiles.each do |col, col_tiles|
        col_tiles.each do |row, tile_obj|
          if col != tile_obj.col || row != tile_obj.row
            move_tile_obj(col, row, tile_obj.col, tile_obj.row)
          end
        end
      end
    end

    def update_laser_blocks(frame_time)
      laser_blocks = tiles.values.flat_map(&.values)
        .select(LaserBlock)
        .map { |tile_obj| tile_obj.as(LaserBlock) }

      laser_blocks.each do |laser_block|
        laser_block.update(frame_time, self)
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
      rect.size = SF.vector2f(tile_size, tile_size)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = TileGridColor
      rect.outline_thickness = TileGridOutlineThickness
      rect.position = {col * tile_size, row * tile_size}

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
