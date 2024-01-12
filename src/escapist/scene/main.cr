require "../room_data"
require "../floor"
require "../hud"
require "../room"
require "../block"
require "../message"

module Escapist::Scene
  class Main < GSF::Scene
    getter view : View
    getter hud
    getter floor

    TopBorder = 64
    BottomBorder = 64
    HorizontalBorder = 16
    RoomSection = 15

    def initialize(window, is_random_room = false)
      super(:main)

      @view = View.from_default(window).dup

      view.reset(HorizontalBorder, TopBorder, width, height)
      view.zoom(1 / Screen.scaling_factor)
      view.viewport(
        x: HorizontalBorder / Screen.width,
        y: TopBorder / Screen.height,
        width: width / Screen.width,
        height: height / Screen.height
      )

      @hud = HUD.new

      room_data = RoomData.load
      first_room_key = room_data.rooms.keys.first

      if is_random_room || first_room_key.empty?
        first_room_key = room_data.rooms.keys.sample
      end

      @floor = Floor.new(view, room_data.rooms, first_room_key)

      @message = CenteredMessage.new(
        screen_width: width,
        screen_height: height,
        message: "This is just a test. Stay calm, there is no reason to be alarmed. Everything will be fine. Uh... I think."
      )
      @message.start
    end

    def width
      Screen.width - HorizontalBorder * 2
    end

    def height
      Screen.height - TopBorder - BottomBorder
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        @exit = true
        return
      end

      floor.update(frame_time, keys)
      hud.update(frame_time)
    end

    def draw(window)
      view.set_current

      floor.draw(window)

      view.set_default_current

      @message.draw(window)
      draw_border(window)
      hud.draw(window)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {HorizontalBorder, TopBorder}

      window.draw(rect)
    end
  end
end
