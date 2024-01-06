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
      @x = 0
      @y = 0
      @width = width
      @height = height

      @player = Player.new(x: 0, y: 0)

      update_viewport
    end

    def update(frame_time, keys : Keys)
      player.update(frame_time, keys, width, height)

      update_viewport
    end

    def update_viewport
      padding = 128
      cx = width / 2
      cy = height / 2

      cx = view.size.x / 2 - padding if cx > view.size.x / 2
      cy = view.size.y / 2 - padding if cy > view.size.y / 2
      cx = player.x + player.size / 2 if player.x + player.size / 2 > cx
      cy = player.y + player.size / 2 if player.y + player.size / 2 > cy
      cx = view.size.x + padding if cx > view.size.x + padding
      cy = view.size.y + padding if cy > view.size.y + padding

      view.center(cx, cy)
    end

    def draw(window : SF::RenderWindow)
      player.draw(window, x, y)
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
