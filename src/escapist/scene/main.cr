require "../hud"
require "../floor"
require "../room"
require "../block"

module Escapist::Scene
  class Main < GSF::Scene
    getter view : View
    getter hud
    getter floor

    TopBorder = 64
    BottomBorder = 64
    HorizontalBorder = 16
    RoomSection = 15

    def initialize(window)
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

      blocks = {
        5 => {
          13 => :block,
          18 => :block
        },
        13 => {
          3 => :block
        },
        7 => {
          7 => :block,
          8 => :block,
          9 => :block
        },
        8 => {
          7 => :block,
          8 => :block,
          9 => :block
        },
        9 => {
          7 => :block,
          8 => :block,
          9 => :block
        }
      }

      rooms = {
        :first => Room.new(RoomSection * 3, RoomSection * 2, RoomDoors.new(top: [:TL, :TR], left: [:LT, :LB], bottom: [:B, nil], right: [:R]), blocks),
        :B => Room.new(RoomSection, RoomSection, RoomDoors.new(top: [:first])),
        :TL => Room.new(RoomSection, RoomSection, RoomDoors.new(bottom: [:first], right: [:TR])),
        :TR => Room.new(RoomSection, RoomSection, RoomDoors.new(bottom: [:first], left: [:TL]))
      }

      @floor = Floor.new(view, rooms, :first)
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
