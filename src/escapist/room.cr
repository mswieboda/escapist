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

      @player = Player.new(x: 0, y: 0)

      view.center(width / 2, height / 2)
    end

    def update(frame_time, keys : Keys)
      player.update(frame_time, keys, width, height)

      update_viewport(frame_time)
    end

    def update_viewport(frame_time)
      padding = 512
      dx = 0
      dy = 0

      dx = -1 if player.x < view.center.x - view.size.x / 2
      dx = 1 if player.x + player.size > view.center.x + view.size.x / 2
      dy = -1 if player.y < view.center.y - view.size.y / 2
      dy = 1 if player.y + player.size > view.center.y + view.size.y / 2

      view.center(view.center.x + dx * padding, view.center.y + dy * padding)
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
