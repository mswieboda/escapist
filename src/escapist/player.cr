require "./box"

module Escapist
  class Player
    getter x : Float32 | Int32
    getter y : Float32 | Int32
    getter? sprinting
    getter sprint_timer : Timer
    getter sprint_wait_timer : Timer

    Radius = 64
    Size = Radius * 2

    Speed = 640
    SprintSpeed = 1280
    SprintDuration = 500.milliseconds
    SprintWaitDuration = 300.milliseconds

    Color = SF::Color.new(153, 0, 0, 30)
    OutlineColor = SF::Color.new(153, 0, 0)
    OutlineThickness = 4

    def initialize(x = 0, y = 0)
      @x = x
      @y = y
      @sprinting = false
      @sprint_timer = Timer.new(SprintDuration)
      @sprint_wait_timer = Timer.new(SprintWaitDuration, true)
    end

    def update(frame_time, keys : Keys, room)
      update_movement(frame_time, keys, room)
      update_sprinting(keys)
    end

    def update_movement(frame_time, keys : Keys, room)
      dx = 0
      dy = 0

      dy -= 1 if keys.pressed?([Keys::W])
      dx -= 1 if keys.pressed?([Keys::A])
      dy += 1 if keys.pressed?([Keys::S])
      dx += 1 if keys.pressed?([Keys::D])

      return if dx == 0 && dy == 0

      dx, dy = move_with_speed(dx, dy, frame_time)
      dx, dy = move_with_room(dx, dy, room)

      return if dx == 0 && dy == 0

      move(dx, dy)
    end

    def move_with_speed(dx, dy, frame_time)
      speed = sprinting? ? SprintSpeed : Speed

      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed

      dx *= (directional_speed * frame_time).to_f32
      dy *= (directional_speed * frame_time).to_f32

      {dx, dy}
    end

    def move_with_room(dx, dy, room)
      dx, dy = move_with_room_bounds(dx, dy, room)

      return {dx, dy} if dx == 0 && dy == 0

      dx, dy = move_with_room_collisions(dx, dy, room.tiles)

      {dx, dy}
    end

    def move_with_room_bounds(dx, dy, room)
      # room wall collisions
      dx = 0 if x + dx < 0 || x + dx + size > room.width
      dy = 0 if y + dy < 0 || y + dy + size > room.height

      {dx, dy}
    end

    def move_with_room_collisions(dx, dy, tiles)
      cells_near = TileObj.cells_near(x + dx, y + dy)

      cells_near.each do |(col, row)|
        next unless tiles.has_key?(col) && tiles[col].has_key?(row)
        next unless tile_obj = tiles[col][row]
        next unless tile_obj.collidable?

        dx = 0 if Box.new(x + dx, y, size, size).collision?(tile_obj.collision_box)
        dy = 0 if Box.new(x, y + dy, size, size).collision?(tile_obj.collision_box)

        break if dx == 0 && dy == 0
      end

      {dx, dy}
    end

    def update_sprinting(keys)
      if (sprinting? && !sprint_timer.done?) || (sprint_wait_timer.done? && keys.just_pressed?([Keys::LShift, Keys::RShift]))
        if !sprinting?
          @sprinting = true
          sprint_timer.restart
        else
          sprint_wait_timer.restart
        end
      else
        @sprinting = false
      end
    end

    def draw(window : SF::RenderWindow)
      circle = SF::CircleShape.new(Radius - OutlineThickness)
      circle.fill_color = Color
      circle.outline_color = OutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {x, y}

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
