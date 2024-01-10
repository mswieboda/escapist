require "./cursor"
require "./block"

module Escapist
  class RoomEditor
    getter view : View
    getter cursor
    property room : Room
    getter? has_tile
    getter place_sound
    getter switch_sound

    Padding = 56

    PlaceTypes = [nil, :block, :floor_switch]

    PlaceSound = SF::SoundBuffer.from_file("./assets/cursor.wav")
    PlaceSoundPitchDecrease = 0.33
    PlaceSoundPitchVariation = 0.13

    SwitchSound = SF::SoundBuffer.from_file("./assets/cursor_switch.wav")
    SwitchSoundVolume = 33
    SwitchSoundPitchVariation = 0.13

    XFontSize = 48
    XTextColor = SF::Color.new(153, 0, 0, 125)

    def initialize(view, room)
      @view = view
      @room = room
      @cursor = Cursor.new(col: 0, row: 0)
      @place_type_index = 0
      @has_tile = false
      @place_sound = SF::Sound.new(PlaceSound)
      @switch_sound = SF::Sound.new(SwitchSound)
      @switch_sound.volume = SwitchSoundVolume
    end

    def place_type_sym
      PlaceTypes[@place_type_index]
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

        unless switch_sound.status == SF::SoundSource::Status::Playing
          switch_sound.pitch = 1 - SwitchSoundPitchVariation / 2 + rand(SwitchSoundPitchVariation)
          switch_sound.play
        end
      end

      @has_tile = room.tile_obj?(cursor.col, cursor.row)

      if has_tile?
        return unless keys.just_pressed?(Keys::Space)

        room.remove_tile_obj(cursor.col, cursor.row)
        play_place_sound(remove: true)
      else
        if place_type = place_type_sym
          return unless keys.just_pressed?(Keys::Space)

          room.add_tile_obj(place_type, cursor.col, cursor.row)
          play_place_sound
        end
      end
    end

    def play_place_sound(remove = false)
      unless place_sound.status == SF::SoundSource::Status::Playing
        place_sound.pitch = 1 + ((remove ? -1 : 1) * PlaceSoundPitchDecrease) - PlaceSoundPitchVariation / 2 + rand(PlaceSoundPitchVariation)
        place_sound.play
      end
    end

    def draw(window : SF::RenderWindow)
      room.draw(window, nil)

      if has_tile?
        draw_x(window)
      else
        case place_type_sym
          when :block
            Block.new(cursor.col, cursor.row).draw(window)
          when :floor_switch
            FloorSwitch.new(cursor.col, cursor.row).draw(window)
        end
      end

      cursor.draw(window)
    end

    def draw_x(window)
      text = SF::Text.new("X", Font.default, XFontSize)
      text.fill_color = XTextColor
      text.position = {
        cursor.x + (cursor.size - text.global_bounds.width) / 2,
        cursor.y + (cursor.size - text.global_bounds.height) / 2
      }

      window.draw(text)
    end
  end
end
