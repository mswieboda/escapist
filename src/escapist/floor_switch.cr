require "./switch"

module Escapist
  class FloorSwitch < Switch
    Key = "fsw"
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

    def initialize(col = 0, row = 0, on = false)
      super("floor", col, row, on)
    end

    def self.key
      Key
    end

    def draw(window : SF::RenderWindow)
      draw_background(window)
      draw_switch_circle(window)
    end

    def draw_background(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(size, size)
      rect.fill_color = Color
      rect.position = {x, y}

      window.draw(rect)
    end

    def draw_switch_circle(window)
      circle = SF::CircleShape.new((size / 2).to_i)
      circle.fill_color = Color
      circle.outline_color = OutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {x, y}

      window.draw(circle)
    end
  end
end
