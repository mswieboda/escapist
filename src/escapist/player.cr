require "./box"
require "./movable_block"

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

    def size
      Size
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

      area_checks(room)
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

      dx, dy = move_with_room_collisions(dx, dy, room)

      {dx, dy}
    end

    def move_with_room_bounds(dx, dy, room)
      # room wall collisions
      dx = 0 if x + dx < 0 || x + dx + size > room.width
      dy = 0 if y + dy < 0 || y + dy + size > room.height

      {dx, dy}
    end

    def move_with_room_collisions(dx, dy, room)
      collidables = room.tiles_near(x + dx, y + dy).select(&.collidable?)

      if moved = move_with_room_movables(dx, dy, room, collidables)
        dx, dy = moved
        return {dx, dy}
      end

      collidables.each do |tile_obj|
        dx = 0 if collision?(tile_obj.collision_box, dx)
        dy = 0 if collision?(tile_obj.collision_box, 0, dy)

        break if dx == 0 && dy == 0
      end

      {dx, dy}
    end

    def move_with_room_movables(dx, dy, room, collidables)
      collidables.select(&.movable?).each do |tile_obj|
        if collision?(tile_obj.collision_box, dx, dy)
          dx, dy = movable_speed(dx, dy)

          # TODO: fix moving past walls or through other collidables
          #       this is gonna suck :)

          # NOTE: checks ensure movable can't move in both directions simultaneously
          if dx.abs > 0 && left_or_right_of_movable?(tile_obj)
            adjusted_dx = if dx > 0
              dx * 1.5 + [x + size - tile_obj.x, 0].min
            else
              dx * 1.5 + [x - tile_obj.x + tile_obj.size, 0].min
            end

            tile_obj.move(adjusted_dx, 0)

            return {dx, dy}
          elsif dy.abs > 0 && above_or_below_of_movable?(tile_obj)
            adjusted_dy = if dy > 0
              dy * 1.5 + [y + size - tile_obj.y, 0].min
            else
              dy * 1.5 + [y - tile_obj.y + tile_obj.size, 0].min
            end

            tile_obj.move(0, adjusted_dy)

            return {dx, dy}
          end
        end
      end
    end

    def area_checks(room)
      areas = room.tiles_near(x, y).select(&.area?)
      areas_entered = areas.select(&.area_entered?)
      areas_not_entered = areas.reject(&.area_entered?)

      areas_entered.each do |tile_obj|
        next if collision?(tile_obj.area_box)

        tile_obj.area_exited
      end

      areas_not_entered.each do |tile_obj|
        tile_obj.area_entered if collision?(tile_obj.area_box)
      end
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

    def collision?(box : Box, dx = 0, dy = 0)
      Box.new(x + dx, y + dy, size).collision?(box)
    end

    def movable_speed(dx, dy)
      # get what speed was prior to movable
      speed = sprinting? ? SprintSpeed : Speed
      directional_speed = dx != 0 && dy != 0 ? speed / 1.4142 : speed

      # slow down to normal speed / 2 when moving stuff
      dx = ((dx / directional_speed) * Speed / 2).to_f32
      dy = ((dy / directional_speed) * Speed / 2).to_f32

      {dx, dy}
    end

    def left_or_right_of_movable?(tile_obj : TileObj)
      (x + size / 2 <= tile_obj.x || x >= tile_obj.x + tile_obj.size / 2) &&
        (y + size / 2 >= tile_obj.y && y + size / 2 <= tile_obj.y + size)
    end

    def above_or_below_of_movable?(tile_obj : TileObj)
      (y + size / 2 <= tile_obj.y || y >= tile_obj.y + tile_obj.size / 2) &&
        (x + size / 2 >= tile_obj.x && x + size / 2 <= tile_obj.x + size)
    end
  end
end
