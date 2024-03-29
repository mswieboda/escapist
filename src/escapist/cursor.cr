module Escapist
  module ScaleHelpers
    #        (b-a)(x - min)
    # f(x) = --------------  + a
    #           max - min
    def scale(new_min, new_max, min, max, x)
      ((new_max - new_min) * (x - min)) / (max - min) + new_min
    end
  end

  class Cursor
    getter col : Int32
    getter row : Int32
    getter? just_moved
    getter move_delay_timer : Timer
    getter move_repeat_delay_timer : Timer
    getter last_cursors
    getter jump_sound
    getter moved_timer : Timer

    include ScaleHelpers

    Size = 128

    MoveDelayDuration = 150.milliseconds
    MoveRepeatDelayDuration = 75.milliseconds
    MovedDuration = 250.milliseconds

    Color = SF::Color.new(153, 0, 0, 25)
    OutlineColor = SF::Color.new(153, 0, 0, 125)
    OutlineThickness = 4

    JumpSound = SF::SoundBuffer.from_file("./assets/cursor.wav")
    JumpSoundVolume = 33
    JumpSoundPitchVariation = 0.13

    def initialize(col = 0, row = 0)
      @col = col
      @row = row
      @just_moved = false
      @move_delay_timer = Timer.new(MoveDelayDuration, true)
      @move_repeat_delay_timer = Timer.new(MoveRepeatDelayDuration, true)
      @last_cursors = [] of LastCursor

      @jump_sound = SF::Sound.new(JumpSound)
      @jump_sound.volume = JumpSoundVolume

      @moved_timer = Timer.new(MovedDuration)
      @moved_timer.start
    end

    def size
      Size
    end

    def x
      col * size
    end

    def y
      row * size
    end

    def update(frame_time, keys : Keys, room_width, room_height)
      update_movement(frame_time, keys, room_width, room_height) if move_repeat_delay_timer.done?

      update_last_cursors()
    end

    def update_movement(frame_time, keys : Keys, room_width, room_height)
      d_col, d_row = get_d_col_row(keys, room_width, room_height)

      if d_col == 0 && d_row == 0
        @just_moved = false
        return
      end

      return unless move_delay_timer.done?

      move_delay_timer.restart unless just_moved?

      @just_moved = true

      move_repeat_delay_timer.restart

      last_cursors << LastCursor.new(col, row)

      jump_to(col + d_col, row + d_row)
    end

    def get_d_col_row(keys, room_width, room_height)
      d_col = 0
      d_row = 0

      d_row -= 1 if keys.pressed?([Keys::W])
      d_col -= 1 if keys.pressed?([Keys::A])
      d_row += 1 if keys.pressed?([Keys::S])
      d_col += 1 if keys.pressed?([Keys::D])

      # check room coords
      d_col = 0 if col + d_col < 0 || (col + d_col + 1) * size > room_width
      d_row = 0 if row + d_row < 0 || (row + d_row + 1) * size > room_height

      {d_col, d_row}
    end

    def update_last_cursors
      last_cursors.select(&.done?).each do |last_cursor|
        last_cursors.delete(last_cursor)
      end
    end

    def draw(window : SF::RenderWindow)
      last_cursors.each(&.draw(window))

      draw_cursor(window)
    end

    def draw_cursor(window)
      percent = [moved_timer.percent, 1].min
      p_size = size * scale(0.775, 1, 0, 1, percent)

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(p_size, p_size)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {
        x + (size - p_size) / 2,
        y + (size - p_size) / 2
      }

      window.draw(rect)
    end

    def jump_to(col, row)
      @col = col
      @row = row

      unless jump_sound.status == SF::SoundSource::Status::Playing
        jump_sound.pitch = 1 - JumpSoundPitchVariation / 2 + rand(JumpSoundPitchVariation)
        jump_sound.play
      end

      moved_timer.restart
    end
  end

  class LastCursor
    getter col : Float32 | Int32
    getter row : Float32 | Int32
    getter remove_timer : Timer

    delegate done?, to: @remove_timer

    Size = 128
    RemoveDuration = 500.milliseconds
    InitialSize = 0.69
    InitialAlpha = 125
    OutlineThickness = 4

    def initialize(col = 0, row = 0)
      @col = col
      @row = row
      @remove_timer = Timer.new(RemoveDuration)

      @remove_timer.start
    end

    def size
      Size
    end

    def x
      col * size
    end

    def y
      row * size
    end

    def draw(window)
      percent = [remove_timer.percent, 1].min
      p_size = size * (1 - percent) * InitialSize
      alpha = ((InitialAlpha - InitialAlpha * percent) * InitialSize).to_i

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(p_size, p_size)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(153, 0, 0, alpha)
      rect.outline_thickness = OutlineThickness
      rect.position = {
        x + (size - p_size) / 2 + OutlineThickness,
        y + (size - p_size) / 2 + OutlineThickness
      }

      window.draw(rect)
    end
  end
end
