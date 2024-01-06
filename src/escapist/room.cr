require "./player"

module Escapist
  class Room
    getter view : View
    getter width : Int32
    getter x : Float32
    getter y : Float32
    getter height : Int32
    getter player

    def initialize(view, width, height)
      @view = view
      @x = 0 # view.size.x / 2 - width / 2
      @y = 0 # view.size.x / 2 - width / 2
      @width = width
      @height = height

      @player = Player.new(view: view, x: 0, y: 0)

      view.center(width / 2, height / 2)
    end

    def update(frame_time, keys : Keys)
      player.update(frame_time, keys, width, height)
    end

    def draw(window : SF::RenderWindow)
      player.draw(window)
      draw_border(window)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(99, 99, 99)
      rect.outline_thickness = 10
      rect.position = {x, y}

      window.draw(rect)
    end
  end
end
