require "../hud"
require "../room"

module Escapist::Scene
  class Main < GSF::Scene
    getter view : View
    getter hud
    getter room

    TopBorder = 48
    BottomBorder = 64
    HorizontalBorder = 8

    def initialize(window)
      super(:main)

      @view = View.from_default(window).dup

      view.zoom(1 / Screen.scaling_factor)
      view.viewport(
        x: HorizontalBorder,
        y: TopBorder,
        width: Screen.width - HorizontalBorder * 2,
        height: Screen.height - TopBorder - BottomBorder
      )

      @hud = HUD.new
      @room = Room.new(view)
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      room.update(frame_time, keys)
      hud.update(frame_time)
    end

    def draw(window)
      draw_border(window)
      room.draw(window)
      hud.draw(window)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(view.viewport.width, view.viewport.height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {view.viewport.left, view.viewport.top}

      window.draw(rect)
    end
  end
end
