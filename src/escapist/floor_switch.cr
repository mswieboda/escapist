require "./switch"

module Escapist
  class FloorSwitch < Switch
    Key = "fsw"
    BackgroundColor = SF::Color.new(153, 153, 153, 30)
    OnColor = SF::Color.new(35, 35, 35)
    OffColor = SF::Color.new(51, 51, 51)
    OnOutlineColor = SF::Color.new(0, 102, 0, 50)
    OffOutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

    def initialize(col = 0, row = 0, on = false)
      super("floor", col, row, on)
    end

    def self.key
      Key
    end

    def area?
      true
    end

    def area_entered?
      on?
    end

    def area_entered
      @on = true
    end

    def area_exited
    end

    def draw(window : SF::RenderWindow)
      draw_background(window)
      draw_switch_circle(window)
    end

    def draw_background(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(size, size)
      rect.fill_color = BackgroundColor
      rect.position = {x, y}

      window.draw(rect)
    end

    def draw_switch_circle(window)
      radius = (size / 3).to_i
      circle = SF::CircleShape.new(radius)
      circle.fill_color = on? ? OnColor : OffColor
      circle.outline_color = on? ? OnOutlineColor : OffOutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {x + radius / 2, y + radius / 2}

      window.draw(circle)
    end
  end
end
