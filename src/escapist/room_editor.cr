require "./cursor"

module Escapist
  class RoomEditor
    getter view : View
    getter cursor
    getter room : Room
    getter place_sound

    Padding = 56

    PlaceSound = SF::SoundBuffer.from_file("./assets/cursor.wav")
    PlaceSoundPitchDecrease = 0.33
    PlaceSoundPitchVariation = 0.13

    def initialize(view, room)
      @view = view
      @room = room
      @cursor = Cursor.new(col: 0, row: 0)

      @place_sound = SF::Sound.new(PlaceSound)
    end

    def update(frame_time, keys : Keys)
      cursor.update(frame_time, keys, room.width, room.height)
      update_viewport(room)
      room.update(nil, keys)
    end

    def update_viewport(room : Room)
      room_width_bigger = room.width + Padding * 2 > view.size.x
      room_height_bigger = room.height + Padding * 2 > view.size.y

      cx = room.width / 2
      cx = view.size.x / 2 - Padding if cx > view.size.x / 2 - Padding

      cy = room.height / 2
      cy = view.size.y / 2 - Padding if cy > view.size.y / 2 - Padding

      if room_width_bigger
        cx = cursor.x + cursor.size / 2 if cursor.x + cursor.size / 2 > cx
        cx = room.width - view.size.x / 2 + Padding if cx > room.width - view.size.x / 2 + Padding
      end

      if room_height_bigger
        cy = cursor.y + cursor.size / 2 if cursor.y + cursor.size / 2 > cy
        cy = room.height - view.size.y / 2 + Padding if cy > room.height - view.size.y / 2 + Padding
      end

      view.center(cx, cy)
    end

    def draw(window : SF::RenderWindow)
      room.draw(window, nil)
      cursor.draw(window)
    end
  end
end
