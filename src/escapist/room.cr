require "./player"
# require "./room_doors"
require "./block"
require "./switch"
require "./floor_switch"
require "json"
require "uuid"

module Escapist
  class Room
    include JSON::Serializable

    alias TileObjRow = Hash(Int32, Hash(String, String))
    alias TileObjGrid = Hash(Int32, TileObjRow)
    alias BlockRow = Hash(Int32, Block)
    alias BlockGrid = Hash(Int32, BlockRow)
    alias SwitchRow = Hash(Int32, Switch)
    alias SwitchGrid = Hash(Int32, SwitchRow)

    getter id : String
    getter s_cols : Int32
    getter s_rows : Int32

    # @[JSON::Field(ignore: true, emit_null: true)]
    # getter doors : RoomDoors?

    getter tile_objs : TileObjGrid = TileObjGrid.new

    @[JSON::Field(ignore: true)]
    getter blocks : BlockGrid = BlockGrid.new

    @[JSON::Field(ignore: true)]
    getter switches : SwitchGrid = SwitchGrid.new

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
      @tile_objs = TileObjGrid.new
      @blocks = BlockGrid.new
      @switches = SwitchGrid.new
      # @doors = RoomDoors.new
    end

    def after_initialize
      # {
      #   5 => {
      #     7 => {
      #       "key" => "blk",
      #       "opts" => {
      #         # whatever
      #       }
      #   }
      # }
      tile_objs.each do |col, rows|
        rows.each do |row, tile_data|
          case tile_data["key"]
          when Block.key
            @blocks[col] = BlockRow.new if !@blocks.has_key?(col)
            @blocks[col][row] = Block.new(col, row)
          when FloorSwitch.key
            @switches[col] = SwitchRow.new if !@switches.has_key?(col)
            @switches[col][row] = FloorSwitch.new(col, row)
          else
            puts "Error: TileObj not found for key: #{tile_data["key"]}"
          end
        end
      end
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
      "#{s_cols}x#{s_rows} to: #{tile_objs.values.flat_map(&.keys.size).sum}"
    end

    def tile_obj?(col, row)
      return unless tile_objs.has_key?(col)

      tile_objs[col].has_key?(row)
    end

    def remove_tile_obj(col, row)
      return unless tile_objs.has_key?(col)

      tile_data = tile_objs[col][row]

      grid = case tile_data["key"]
        when Block.key
          @blocks
        when FloorSwitch.key
          @switches
        else
          @blocks
        end

      [tile_objs, grid].each do |hash|
        hash[col].delete(row)
        hash.delete(col) if hash[col].keys.empty?
      end
    end

    def add_tile_obj(place_type : Symbol, col, row)
      case place_type
      when :block
        block = Block.new(col, row)

        tile_objs[col] = TileObjRow.new unless tile_objs.has_key?(col)
        tile_objs[col][row] = block.to_tile_data

        blocks[col] = BlockRow.new unless blocks.has_key?(col)
        blocks[col][row] = block
      when :floor_switch
        switch = FloorSwitch.new(col, row)

        tile_objs[col] = TileObjRow.new unless tile_objs.has_key?(col)
        tile_objs[col][row] = switch.to_tile_data

        switches[col] = SwitchRow.new unless switches.has_key?(col)
        switches[col][row] = switch
      end
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

      blocks.values.flat_map(&.values).each(&.draw(window))
      switches.values.flat_map(&.values).each(&.draw(window))

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
