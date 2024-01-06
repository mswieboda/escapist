require "./font"

module Escapist
  class HUD
    getter text

    Margin = 10

    TextColor = SF::Color::Green

    def initialize
      @text = SF::Text.new("health: 100%", Font.default, 24)
      @text.fill_color = TextColor
      @text.position = {Margin, Margin}
    end

    def update(frame_time)
    end

    def draw(window : SF::RenderWindow)
      window.draw(text)
    end
  end
end
