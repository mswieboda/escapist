require "./switch"

module Escapist
  class LaserSwitch < Switch
    Key = "laser"
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4
    OnColor = SF::Color.new(153, 0, 0, 153)
    OffColor = SF::Color.new(51, 51, 51, 51)
    OnOutlineColor = SF::Color.new(0, 102, 0, 50)
    OffOutlineColor = SF::Color.new(102, 102, 102)
    OnSoundBuffer = SF::SoundBuffer.from_file("./assets/floor_switch_on.wav")
    OnSoundVolume = 33
    OnSoundPitchVariation = 0.03
    OnSound = SF::Sound.new(OnSoundBuffer)
    OnSound.volume = OnSoundVolume

    def initialize(col = 0, row = 0, on = false)
      super(Key, col, row, on)
    end

    def self.key
      Key
    end

    def collidable?
      true
    end

    def center_x
      x + draw_size / 2
    end

    def center_y
      y + draw_size / 2
    end

    def radius
      (draw_size / 3).to_i
    end

    def update(room)
      lasers = room.tiles
        .values.flat_map(&.values)
        .select(LaserBlock)
        .flat_map(&.lasers)

      update_on_off(lasers)
    end

    def update_on_off(lasers)
      turn_on = lasers.any? do |laser|
        laser_point_collision?(laser[:end_x], laser[:end_y])
      end

      if turn_on && !on?
        unless OnSound.status == SF::SoundSource::Status::Playing
          OnSound.pitch = 1 - OnSoundPitchVariation / 2 + rand(OnSoundPitchVariation)
          OnSound.play
        end
      elsif !turn_on && on?
        # TODO: reverse this sound, or use different one
        unless OnSound.status == SF::SoundSource::Status::Playing
          OnSound.pitch = 1 - OnSoundPitchVariation / 2 + rand(OnSoundPitchVariation)
          OnSound.play
        end
      end

      @on = turn_on
    end

    def laser_point_collision?(x, y)
     dx = x - center_x
     dy = y - center_y

     dx * dx + dy * dy <= radius * radius
    end

    def draw(window : SF::RenderWindow)
      draw_block(window)
      draw_switch_circle(window)
    end

    def draw_block(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(draw_size, draw_size)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {x + draw_offset, y + draw_offset}

      window.draw(rect)
    end

    def draw_switch_circle(window)
      circle = SF::CircleShape.new(radius)
      circle.fill_color = on? ? OnColor : OffColor
      circle.origin = {radius / 2, radius / 2}
      circle.outline_color = on? ? OnOutlineColor : OffOutlineColor
      circle.outline_thickness = OutlineThickness
      circle.position = {center_x, center_y}

      window.draw(circle)
    end
  end
end
