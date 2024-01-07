module Escapist
  class Cursor
    getter col : Float32 | Int32
    getter row : Float32 | Int32

    Size = 128

    Color = SF::Color.new(153, 0, 0, 30)
    OutlineColor = SF::Color.new(153, 0, 0)
    OutlineThickness = 4

    def initialize(col = 0, row = 0)
      @col = col
      @row = row
    end

    def size
      Size
    end

    def x
      col * size
    end

    def y
      row * size
    end

    def update(frame_time, keys : Keys, room_width, room_height)
      update_movement(frame_time, keys, room_width, room_height)
    end

    def update_movement(frame_time, keys : Keys, room_width, room_height)
      d_col = 0
      d_row = 0

      d_row -= 1 if keys.just_pressed?([Keys::W])
      d_col -= 1 if keys.just_pressed?([Keys::A])
      d_row += 1 if keys.just_pressed?([Keys::S])
      d_col += 1 if keys.just_pressed?([Keys::D])

      return if d_col == 0 && d_row == 0

      jump_to(col + d_col, row + d_row)
    end

    def draw(window : SF::RenderWindow)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(size, size)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {
        x + OutlineThickness,
        y + OutlineThickness
      }

      window.draw(rect)
    end

    def jump_to(col, row)
      @col = col
      @row = row
    end
  end
end
