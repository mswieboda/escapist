module Escapist
  class Message
    getter cx : Float32 | Int32
    getter y : Float32 | Int32
    getter message : String
    getter text : SF::Text
    getter width : Float32 | Int32
    getter max_width : Float32 | Int32
    getter height : Float32 | Int32
    getter lines : Array(String)

    Padding = 64
    FontSize = 22
    BackgroundColor = SF::Color.new(17, 17, 17, 170)
    TextColor = SF::Color::White
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 8

    def initialize(@cx, @y, @max_width, @message = "")
      @text = SF::Text.new(message, Font.default, FontSize)
      @text.line_spacing = 2
      @text.fill_color = TextColor

      text_width = @text.global_bounds.width

      @width = [text_width, @max_width].min
      @lines = @width < text_width ? calc_lines : [@message]
      @text.string = lines.join("\n")
      @height = @text.global_bounds.height

      # TODO: clear text to animate it
      # @text.string = ""

      @text.position = {x, y}
    end

    def x
      cx - width / 2
    end

    def calc_lines
      lines = [""]
      line_index = 0
      text.string = " "
      char_width = text.global_bounds.width.to_i
      chars_per_line = (@width / char_width).to_i

      message.split.each do |word|
        if lines[line_index].size + word.size > chars_per_line
          line_index += 1
          lines << word
        else
          lines[line_index] += "#{word} "
        end
      end

      lines
    end

    def draw(window : SF::RenderWindow)
      draw_border(window)
      draw_text(window)
    end

    def draw_text(window)
      window.draw(text)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width + Padding * 2, height + Padding * 2)
      rect.fill_color = BackgroundColor
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {x - Padding, y - Padding}

      window.draw(rect)
    end
  end
end
