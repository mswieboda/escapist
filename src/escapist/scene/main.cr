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

      # TODO: figure out how the viewport works
      # view.viewport(
      #   x: HorizontalBorder,
      #   y: TopBorder,
      #   width: Screen.width - HorizontalBorder * 2,
      #   height: Screen.height - TopBorder - BottomBorder
      # )
      # view.resize(Screen.width - HorizontalBorder * 2, Screen.height - TopBorder - BottomBorder)
      view.zoom(1 / Screen.scaling_factor)

      @hud = HUD.new
      @room = Room.new(view, 1920, 1280)
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
      view.set_current

      room.draw(window)

      view.set_default_current

      hud.draw(window)
      draw_border(window)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(view.size.x, view.size.y)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {HorizontalBorder, TopBorder}

      window.draw(rect)
    end
  end
end
