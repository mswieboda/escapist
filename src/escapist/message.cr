module Escapist
  class Message
    @width : Float32 | Int32
    @height : Float32 | Int32
    @typing_timer : Timer
    @animate_timer : Timer

    getter cx : Float32 | Int32
    getter y : Float32 | Int32
    getter message : String
    getter text : SF::Text
    getter max_width : Float32 | Int32
    getter? typing
    getter message_typed : String
    getter? animate

    Padding = 64
    FontSize = 28
    LineSpacing = 2.25
    TypeDuration = 69.milliseconds
    AnimateDuration = 300.milliseconds
    BackgroundColor = SF::Color.new(17, 17, 17, 170)
    TextColor = SF::Color::White
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 8

    def initialize(@cx, @y, @max_width, @message = "", @typing = false, @animate = false)
      @text = SF::Text.new(message, Font.default, FontSize)
      @text.line_spacing = LineSpacing
      @text.fill_color = TextColor

      text_width = @text.global_bounds.width

      @width = [text_width, @max_width].min
      lines = @width < text_width ? calc_lines : [@message]
      @message = lines.join("\n")
      @text.string = @message
      @height = @text.global_bounds.height

      @typing_timer = Timer.new(TypeDuration * @message.size)
      @message_typed = ""

      @text.string = typing? ? "" : @message

      @animate_timer = Timer.new(AnimateDuration)

      @text.position = {x, y}
    end

    def start
      @typing_timer.start
      @animate_timer.start if animate?
    end

    def x
      cx - width / 2
    end

    def width
      if animate?
        @width * [@animate_timer.percent, 1].min
      else
        @width
      end
    end

    def height
      if animate?
        @height * [@animate_timer.percent, 1].min
      else
        @height
      end
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
          lines << ""
        end

        lines[line_index] += "#{word} "
      end

      lines
    end

    def draw(window : SF::RenderWindow)
      draw_border(window)
      draw_text(window)
    end

    def draw_text(window)
      if typing?
        index = (@message.size * [@typing_timer.percent, 1].min).to_i
        text.string = @message[0..index]
      end

      @text.position = {x, y} if animate?

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

  class CenteredMessage < Message
    def initialize(screen_width, screen_height, message = "", typing = true, animate = true)
      super(
        cx: (screen_width / 2).to_i,
        y: (screen_height / 2 + screen_height / 4).to_i,
        max_width: (screen_width / 2.5).to_i,
        message: message,
        typing: typing,
        animate: animate
      )
    end
  end
end
