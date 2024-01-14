require "./font"

module Escapist
  class MiniMap
    @tr_x : Int32
    @tr_y : Int32
    @floor_data : FloorData
    @floor : Floor

    delegate :grid, to: @floor_data
    delegate :rooms, to: @floor_data

    Margin = 32
    CellSize = 48

    BorderOutlineColor = SF::Color.new(153, 153, 153)
    BorderOutlineThickness = 2

    CellColor = SF::Color.new(51, 51, 51, 51)
    CellInColor = SF::Color.new(51, 51, 51, 153)
    CellOutlineColor = SF::Color.new(153, 153, 153, 51)
    CellOutlineThickness = 2

    def initialize(@tr_x, @tr_y, @floor_data, @floor)
    end

    def width
      grid[0].size * CellSize
    end

    def height
      grid.size * CellSize
    end

    def x
      @tr_x - Margin - width
    end

    def y
      @tr_y + Margin
    end

    def draw(window : SF::RenderWindow)
      # draw_border(window)
      draw_grid(window)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = BorderOutlineColor
      rect.outline_thickness = BorderOutlineThickness
      rect.position = {x, y}

      window.draw(rect)
    end

    def draw_grid(window)
      drawn_rooms = [] of String

      grid.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          next if cell == "" || drawn_rooms.includes?(cell)

          if room = rooms[cell]
            draw_room(window, row_index, col_index, room, @floor.room_key == cell)
            drawn_rooms << room.key
          end
        end
      end
    end

    def draw_room(window, row_index, col_index, room, is_player_in = false)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(
        room.s_cols * CellSize - CellOutlineThickness * 2,
        room.s_rows * CellSize - CellOutlineThickness * 2
      )
      rect.fill_color = is_player_in ? CellInColor : CellColor
      rect.outline_color = CellOutlineColor
      rect.outline_thickness = CellOutlineThickness
      rect.position = {x + col_index * CellSize, y + row_index * CellSize}

      window.draw(rect)
    end
  end
end
