module Escapist::Scene
  class Start < GSF::Scene
    getter start_scene : Symbol?
    getter items

    def initialize
      super(:start)

      @start_scene = nil
      @items = GSF::MenuItems.new(
        font: Font.default,
        items: ["start", "editor", "exit"],
        initial_focused_index: 0
      )
    end

    def reset
      super

      @start_scene = nil
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      items.update(frame_time, keys, mouse)

      if @items.selected?(keys, mouse, joysticks)
        case items.focused_label
        when "start"
          @start_scene = :main
        when "editor"
          @start_scene = :editor
        when "exit"
          @exit = true
        end
      elsif keys.just_pressed?(Keys::Escape)
        @exit = true
      end
    end

    def draw(window : SF::RenderWindow)
      items.draw(window)
    end
  end
end
