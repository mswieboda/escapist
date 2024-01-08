require "./cursor"
require "./block"

module Escapist
  class RoomEditor
    getter view : View
    getter cursor
    property room : Room
    getter place_sound

    Padding = 56

    PlaceTypes = [nil, :block, :floor_switch]

    PlaceSound = SF::SoundBuffer.from_file("./assets/cursor.wav")
    PlaceSoundPitchDecrease = 0.33
    PlaceSoundPitchVariation = 0.13

    def initialize(view, room)
      @view = view
      @room = room
      @cursor = Cursor.new(col: 0, row: 0)
      @place_sound = SF::Sound.new(PlaceSound)
      @place_type_index = 0
    end

    def update(frame_time, keys : Keys)
      cursor.update(frame_time, keys, room.width, room.height)
      update_viewport(room)
      room.update(nil, keys)

      update_editing(keys)
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

    def update_editing(keys : Keys)
      if keys.just_pressed?(Keys::Tab)
        @place_type_index += 1
        @place_type_index = 0 if @place_type_index > PlaceTypes.size - 1
      end

      if room.tile_obj?(cursor.col, cursor.row)
        return unless keys.just_pressed?(Keys::Space)

        room.remove_tile_obj(cursor.col, cursor.row)
        play_sound(remove: true)
      else
        if place_type = PlaceTypes[@place_type_index]
          return unless keys.just_pressed?(Keys::Space)

          room.add_tile_obj(place_type, cursor.col, cursor.row)
          play_sound
        end
      end
    end

    def play_sound(remove = false)
      unless place_sound.status == SF::SoundSource::Status::Playing
        place_sound.pitch = 1 + ((remove ? -1 : 1) * PlaceSoundPitchDecrease) - PlaceSoundPitchVariation / 2 + rand(PlaceSoundPitchVariation)
        place_sound.play
      end
    end

    def draw(window : SF::RenderWindow)
      room.draw(window, nil)
      cursor.draw(window)
    end
  end
end
