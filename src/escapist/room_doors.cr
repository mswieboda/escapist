module Escapist
  class RoomDoors
    getter top : Array(Symbol)
    getter left : Array(Symbol)
    getter bottom : Array(Symbol)
    getter right : Array(Symbol)
    getter entered : Symbol | Nil

    Depth = 32
    Width = 192
    OutlineThickness = 8

    def initialize(top = [] of Symbol, left = [] of Symbol, bottom = [] of Symbol, right = [] of Symbol)
      @top = top
      @left = left
      @bottom = bottom
      @right = right
      @entered = nil
    end

    def update(player : Player, keys : Keys, room_width, room_height)
      check_doors(
        player,
        room_width,
        room_height,
        top,
        "top",
        keys.just_pressed?(Keys::W)
      )

      check_doors(
        player,
        room_width,
        room_height,
        left,
        "left",
        keys.just_pressed?(Keys::A),
        horz: false
      )

      check_doors(
        player,
        room_width,
        room_height,
        bottom,
        "bottom",
        keys.just_pressed?(Keys::S),
        far: true
      )

      check_doors(
        player,
        room_width,
        room_height,
        right,
        "right",
        keys.just_pressed?(Keys::D),
        horz: false,
        far: true
      )
    end

    def through_door(name, index, door)
      @entered = door
    end

    def clear_entered
      @entered = nil
    end

    def door_center(doors, index, room_width, room_height, horz = true, far = false)
      cx = !horz && far ? room_width : 0
      cy = horz && far ? room_height : 0

      if horz
        cx = room_width / (1 + doors.size) * (index + 1)
      else
        cy = room_height / (1 + doors.size) * (index + 1)
      end

      {cx.to_f32, cy.to_f32}
    end

    def check_doors(player, room_width, room_height, doors, name : String, key_pressed, horz = true, far = false)
      if !@entered && key_pressed
        doors.each_with_index do |door, index|
          cx, cy = door_center(doors, index, room_width, room_height, horz, far)

          if in_door?(player, cx, cy, horz, far)
            return through_door(name, index, door)
          end
        end
      end
    end

    def in_door?(player, cx, cy, horz = true, far = false)
      width = horz ? Width : Depth
      height = horz ? Depth : Width
      x = cx - width / 2
      y = cy - height / 2

      if horz
        return unless player.x >= x && player.x + player.size <= x + width

        if far
          player.y + player.size > y
        else
          player.y < y + height
        end
      else
        return unless player.y >= y && player.y + player.size <= y + height

        if far
          player.x + player.size > x
        else
          player.x < x + width
        end
      end
    end

    def spawn_player(player, room_key, room_width, room_height)
      player_half_size = player.size / 2

      if index = top.index(room_key)
        cx, cy = door_center(top, index, room_width, room_height)

        player.jump_to(cx - player_half_size, cy)
      elsif index = left.index(room_key)
        cx, cy = door_center(left, index, room_width, room_height, horz: false)

        player.jump_to(cx, cy + player.size)
      elsif index = bottom.index(room_key)
        cx, cy = door_center(bottom, index, room_width, room_height, far: true)

        player.jump_to(cx - player_half_size, cy - player.size)
      elsif index = right.index(room_key)
        cx, cy = door_center(right, index, room_width, room_height, horz: false, far: true)

        player.jump_to(cx, cy - player.size)
      end
    end

    def draw(window, room_width, room_height)
      top.each_with_index do |door, index|
        x = room_width / (1 + top.size) * (index + 1)

        draw_door(window, x, 0, horz: true)
      end

      left.each do |door|
        y = room_height / (1 + left.size)

        draw_door(window, 0, y, horz: false)
      end

      bottom.each do |door|
        x = room_width / (1 + bottom.size)
        y = room_height

        draw_door(window, x, y, horz: true)
      end

      right.each do |door|
        x = room_width
        y = room_height / (1 + right.size)

        draw_door(window, x, y, horz: false)
      end
    end

    def draw_door(window, x, y, horz = true)
      width = horz ? Width : Depth
      height = horz ? Depth : Width

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Red
      rect.outline_color = SF::Color.new(99, 99, 99)
      rect.outline_thickness = OutlineThickness
      rect.position = {x - width / 2, y - height / 2}

      window.draw(rect)
    end
  end
end
