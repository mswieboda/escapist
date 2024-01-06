module Escapist
  class RoomDoors
    getter top : Array(Symbol)
    getter left : Array(Symbol)
    getter bottom : Array(Symbol)
    getter right : Array(Symbol)

    Depth = 32
    Width = 192
    OutlineThickness = 8

    def initialize(top = [] of Symbol, left = [] of Symbol, bottom = [] of Symbol, right = [] of Symbol)
      @top = top
      @left = left
      @bottom = bottom
      @right = right
    end

    def update(player : Player, keys : Keys, room_width, room_height)
      top.each_with_index do |door, index|
        break unless keys.just_pressed?(Keys::W)

        cx = room_width / (1 + top.size) * (index + 1)

        if in_door?(player, cx, 0, horz: true)
          return through_door("top", index, door)
        end
      end

      left.each_with_index do |door, index|
        break unless keys.just_pressed?(Keys::A)

        cy = room_height / (1 + left.size) * (index + 1)

        if in_door?(player, 0, cy, horz: false)
          return through_door("left", index, door)
        end
      end

      bottom.each_with_index do |door, index|
        break unless keys.just_pressed?(Keys::S)

        cx = room_width / (1 + right.size) * (index + 1)

        if in_door?(player, cx, room_height, horz: true, far: true)
          return through_door("bottom", index, door)
        end
      end

      right.each_with_index do |door, index|
        break unless keys.just_pressed?(Keys::D)

        cy = room_height / (1 + right.size) * (index + 1)

        if in_door?(player, room_width, cy, horz: false, far: true)
          return through_door("right", index, door)
        end
      end
    end

    def through_door(name, index, door)
      puts ">>> went through top door #{index}: #{door}"
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
