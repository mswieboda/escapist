require "./player"

module Escapist
  class Floor
    @room : Room | Nil

    getter view : View
    getter player
    getter rooms : Array(Room)

    def initialize(view, rooms = [] of Room)
      @view = view
      @player = Player.new(x: 0, y: 0)
      @rooms = rooms
      @room = rooms.first

      if room = @room
        room.player = @player
      end
    end

    def update(frame_time, keys : Keys)
      if room = @room
        player.update(frame_time, keys, room.width, room.height)
        room.update(frame_time, keys)
        update_viewport(room)
      end
    end

    def update_viewport(room : Room)
      padding = 128
      cx = room.width / 2
      cy = room.height / 2
      cx = view.size.x / 2 - padding if cx > view.size.x / 2
      cy = view.size.y / 2 - padding if cy > view.size.y / 2
      cx = player.x + player.size / 2 if room.width > view.size.x && player.x + player.size / 2 > cx
      cy = player.y + player.size / 2 if room.height > view.size.y && player.y + player.size / 2 > cy
      cx = view.size.x + padding if cx > view.size.x + padding
      cy = view.size.y + padding if cy > view.size.y + padding

      view.center(cx, cy)
    end

    def draw(window : SF::RenderWindow)
      rooms.each do |room|
        room.draw(window, @room ? player : nil)
      end
    end
  end
end
