module Escapist
  class Player
    getter view : View
    getter x : Int32
    getter y : Int32
    getter animations

    Speed = 15
    Radius = 64
    Size = Radius * 2
    OutlineThickness = 4

    def initialize(view, x = 0, y = 0)
      @view = view
      @x = x
      @y = y
    end

    def update(_frame_time, keys : Keys, room_width, room_height)
      update_movement(keys, room_width, room_height)
    end

    def update_movement(keys : Keys, room_width, room_height)
      dx = 0
      dy = 0

      dy -= Speed if keys.pressed?([Keys::W])
      dx -= Speed if keys.pressed?([Keys::A])
      dy += Speed if keys.pressed?([Keys::S])
      dx += Speed if keys.pressed?([Keys::D])

      # TODO: use room sizing in these checks instead of viewport
      dx = 0 if x + dx < 0 || x + dx + Size > room_width
      dy = 0 if y + dy < 0 || y + dy + Size > room_height

      move(dx, dy) if dx != 0 || dy != 0
    end

    def draw(window : SF::RenderWindow)
      window.draw(circle)
    end

    def circle
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = SF::Color::Transparent
      circle.outline_color = SF::Color::Red
      circle.outline_thickness = OutlineThickness
      circle.position = {
        view.viewport.left + x + OutlineThickness,
        view.viewport.top + y + OutlineThickness
      }

      circle
    end

    def move(dx : Int32, dy : Int32)
      @x += dx
      @y += dy
    end
  end
end
