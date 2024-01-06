require "./player"

module Escapist
  class Room
    getter x : Float32 | Int32
    getter y : Float32 | Int32
    getter width : Int32
    getter height : Int32

    OutlineThickness = 8

    def initialize(x, y, width, height)
      @player = nil
      @x = x
      @y = y
      @width = width
      @height = height
    end

    def update(frame_time, keys : Keys)

    end

    def draw(window : SF::RenderWindow, p : Player | Nil)
      draw_border(window)

      if player = p
        player.draw(window)
      end
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(99, 99, 99)
      rect.outline_thickness = OutlineThickness
      rect.position = {x, y}

      window.draw(rect)
    end

    def player=(player : Player)
      @player = player
    end
  end
end
