module Escapist
  class Player
    getter x : Int32
    getter y : Int32
    getter animations

    Speed = 15
    Sheet = "./assets/player.png"

    def initialize(x = 0, y = 0)
      # sprite size
      size = 128
      @x = x
      @y = y

      # init animations
      fps = 60

      # idle
      idle = GSF::Animation.new((fps / 3).to_i, loops: false)
      idle.add(Sheet, 0, 0, size, size)

      # fire animation
      fire_frames = 3
      fire = GSF::Animation.new((fps / 25).to_i, loops: false)

      fire_frames.times do |i|
        fire.add(Sheet, i * size, 0, size, size)
      end

      @animations = GSF::Animations.new(:idle, idle)
      animations.add(:fire, fire)
    end

    def update(frame_time, keys : Keys)
      animations.update(frame_time)

      update_movement(keys)
    end

    def update_movement(keys : Keys)
      dy = 0

      if keys.pressed?(Keys::Up)
        dy -= Speed
      elsif keys.pressed?(Keys::Down)
        dy += Speed
      end

      if y + dy > 0 && y + dy < GSF::Screen.height
        move(0, dy)
      end
    end

    def draw(window : SF::RenderWindow)
      animations.draw(window, x, y)
    end

    def move(dx : Int32, dy : Int32)
      @x += dx
      @y += dy
    end
  end
end
