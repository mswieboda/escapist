require "./player"

module Escapist
  class Room
    getter view : View
    getter player

    def initialize(view)
      @view = view
      @player = Player.new(view: view, x: 128, y: 256)
    end

    def update(frame_time, keys : Keys)
      player.update(frame_time, keys)
    end

    def draw(window : SF::RenderWindow)
      player.draw(window)
    end
  end
end
