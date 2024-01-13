require "json"

module Escapist
  class RoomDoors
    include JSON::Serializable

    alias DoorKey = String | Nil

    getter top = [] of DoorKey
    getter left = [] of DoorKey
    getter bottom = [] of DoorKey
    getter right = [] of DoorKey

    @[JSON::Field(ignore: true)]
    getter entered : DoorKey

    Depth = 96
    Width = 256
    Color = SF::Color.new(13, 13, 13)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 8

    def initialize(top = [] of DoorKey, left = [] of DoorKey, bottom = [] of DoorKey, right = [] of DoorKey)
      @top = top
      @left = left
      @bottom = bottom
      @right = right
      @entered = nil
    end

    def update(player : Player, keys : Keys, room_width, room_height)
      check_all_doors(player, keys, room_width, room_height)
    end

    def clear_entered
      @entered = nil
    end

    def door_center(doors, index, room_width, room_height, horz = true, far = false)
      cx = !horz && far ? room_width : 0
      cy = horz && far ? room_height : 0
      spacing = (horz ? room_width : room_height) / (doors.size * 2)

      if horz
        cx = spacing + room_width / doors.size * index
      else
        cy = spacing + room_height / doors.size * index
      end

      {cx.to_f32, cy.to_f32}
    end

    def check_all_doors(player : Player, keys : Keys, room_width, room_height)
      [
        { top, Keys::W, true, false },
        { left, Keys::A, false, false },
        { bottom, Keys::S, true, true },
        { right, Keys::D, false, true }
      ].each do |config|
        break if check_doors(
          player,
          keys,
          room_width,
          room_height,
          *config
        )
      end
    end

    def check_doors(player, keys, room_width, room_height, doors, key, horz = true, far = false)
      if !@entered && keys.pressed?(key)
        doors.each_with_index do |door, index|
          next unless door

          cx, cy = door_center(doors, index, room_width, room_height, horz, far)

          if in_door?(player, cx, cy, horz, far)
            return @entered = door
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

        player.jump_to(cx, cy - player_half_size)
      elsif index = bottom.index(room_key)
        cx, cy = door_center(bottom, index, room_width, room_height, far: true)

        player.jump_to(cx - player_half_size, cy - player.size)
      elsif index = right.index(room_key)
        cx, cy = door_center(right, index, room_width, room_height, horz: false, far: true)

        player.jump_to(cx - player.size, cy - player_half_size)
      end
    end

    def draw(window, room_width, room_height)
      draw_doors(window, top, room_width, room_height)
      draw_doors(window, left, room_width, room_height, horz: false)
      draw_doors(window, bottom, room_width, room_height, far: true)
      draw_doors(window, right, room_width, room_height, horz: false, far: true)
    end

    def draw_doors(window, doors, room_width, room_height, horz = true, far = false)
      doors.size.times do |index|
        next unless doors[index]
        draw_door(window, doors, index, room_width, room_height, horz, far)
      end
    end

    def draw_door(window, doors, index, room_width, room_height, horz = true, far = false)
      cx, cy = door_center(doors, index, room_width, room_height, horz, far)

      width = horz ? Width : Depth
      height = horz ? Depth : Width

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {cx - width / 2, cy - height / 2}

      window.draw(rect)
    end
  end
end
