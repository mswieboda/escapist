module Escapist
  class Player
    getter x : Float32 | Int32
    getter y : Float32 | Int32
    getter animations

    Speed = 640
    SprintSpeed = 1280
    Radius = 64
    Size = Radius * 2
    Color = SF::Color.new(153, 0, 0, 30)
    OutlineColor = SF::Color.new(153, 0, 0)
    OutlineThickness = 4

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
    end

    def update(frame_time, keys : Keys, room_width, room_height)
      update_movement(frame_time, keys, room_width, room_height)
    end

    def update_movement(frame_time, keys : Keys, room_width, room_height)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?([Keys::W])
      dx -= 1 if keys.pressed?([Keys::A])
      dy += 1 if keys.pressed?([Keys::S])
      dx += 1 if keys.pressed?([Keys::D])

      return if dx == 0 && dy == 0

      move_with_speed(frame_time, keys, room_width, room_height, dx, dy)
    end

    def move_with_speed(frame_time, keys : Keys, room_width, room_height, dx, dy)
      speed = keys.pressed?([Keys::LShift, Keys::RShift]) ? SprintSpeed : Speed
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed

      dx *= (directional_speed * frame_time).to_f32
      dy *= (directional_speed * frame_time).to_f32

      dx = 0 if x + dx < 0 || x + dx + size > room_width
      dy = 0 if y + dy < 0 || y + dy + size > room_height

      move(dx, dy)
    end

    def draw(window : SF::RenderWindow)
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = Color
      circle.outline_color = OutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {
        x + OutlineThickness,
        y + OutlineThickness
      }

      window.draw(circle)
    end

    def move(dx, dy)
      @x += dx
      @y += dy
    end

    def jump_to(x, y)
      @x = x
      @y = y
    end

    def size
      Size
    end
  end
end
