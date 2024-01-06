module Escapist
  class Player
    getter x : Int32
    getter y : Int32
    getter animations

    Speed = 15
    Radius = 64
    Size = Radius * 2
    OutlineThickness = 4

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    def update(_frame_time, keys : Keys)
      # animations.update(frame_time)

      update_movement(keys)
    end

    def update_movement(keys : Keys)
      dy = 0

      if keys.pressed?(Keys::Up)
        dy -= Speed
      elsif keys.pressed?(Keys::Down)
        dy += Speed
      end

      if y + dy > 0 && y + dy + Size < GSF::Screen.height
        move(0, dy)
      end
    end

    def draw(window : SF::RenderWindow)
      window.draw(circle)
    end

    def circle
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = SF::Color::Transparent
      circle.outline_color = SF::Color::Red
      circle.outline_thickness = OutlineThickness
      circle.position = {x + OutlineThickness, y + OutlineThickness}
      circle
    end

    def move(dx : Int32, dy : Int32)
      @x += dx
      @y += dy
    end
  end
end
