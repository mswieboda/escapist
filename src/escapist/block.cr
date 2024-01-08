require "./tile_obj"
require "./box"
require "json"

module Escapist
  class Block < TileObj
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

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
