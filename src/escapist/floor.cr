require "./player"

module Escapist
  class Floor
    @room : Room | Nil
    @room_key : Symbol

    getter view : View
    getter player
    getter rooms : Hash(Symbol, Room)

    def initialize(view, rooms, first_room : Symbol)
      @view = view
      @player = Player.new(x: 0, y: 0)
      @rooms = rooms
      @room_key = first_room
      @previous_room_key = first_room
      @room = rooms[@room_key]
    end

    def update(frame_time, keys : Keys)
      if room = @room
        player.update(frame_time, keys, room.width, room.height)
        update_viewport(room)
        room.update(player, keys)

        if entered = room.entered
          switch_room(entered)
          room.clear_entered
        end
      end
    end

    def update_viewport(room : Room)
      padding = 256

      room_width_bigger = room.width + padding * 2 > view.size.x
      room_height_bigger = room.height + padding * 2 > view.size.y

      cx = room.width / 2
      cx = view.size.x / 2 - padding if cx > view.size.x / 2 - padding

      cy = room.height / 2
      cy = view.size.y / 2 - padding if cy > view.size.y / 2 - padding

      if room_width_bigger
        cx = player.x + player.size / 2 if player.x + player.size / 2 > cx
        cx = room.width - view.size.x / 2 + padding if cx > room.width - view.size.x / 2 + padding
      end

      if room_height_bigger
        cy = player.y + player.size / 2 if player.y + player.size / 2 > cy
        cy = room.height - view.size.y / 2 + padding if cy > room.height - view.size.y / 2 + padding
      end

      view.center(cx, cy)
    end

    def draw(window : SF::RenderWindow)
      if room = @room
        room.draw(window, player)
      end
    end

    def switch_room(room_key)
      if rooms.has_key?(room_key)
        @room = rooms[room_key]

        if room = @room
          room.spawn_player(player, @room_key)
          @room_key = room_key
        end
      end
    end
  end
end
