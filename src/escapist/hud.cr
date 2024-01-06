require "./font"

module Escapist
  class HUD
    getter text

    FontSize = 24
    Margin = 16

    TextColor = SF::Color::Green

    def initialize
      @text = SF::Text.new("health: 100%", Font.default, FontSize)
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
