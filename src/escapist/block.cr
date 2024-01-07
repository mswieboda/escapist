require "./box"

module Escapist
  class Block
    getter col : Int32
    getter row : Int32

    TileSize = 128
    Size = 96
    Offset = 16 # (TileSize - Size) / 2

    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

    def initialize(@col = 0, @row = 0)
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

    def collision_box
      Box.new(x, y, size, size)
    end

    def draw(window : SF::RenderWindow)

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(size, size)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {x, y}

      window.draw(rect)
    end

    def jump_to(col, row)
      @col = col
      @row = row
    end
  end
end
