require "./tile_obj"

module Escapist
  class Block < TileObj
    Key = "blk"
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

    def initialize(col = 0, row = 0)
      super("block", col, row)
    end

    def self.key
      Key
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
  end
end
