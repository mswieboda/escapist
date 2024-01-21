require "./tile_obj"

module Escapist
  class BaseBlock < TileObj
    use_json_discriminator "block", {block: Block, movable: MovableBlock, laser: LaserBlock}

    property block : String

    Key = "block"
    Color = SF::Color.new(153, 153, 153, 30)
    OutlineColor = SF::Color.new(102, 102, 102)
    OutlineThickness = 4

    def initialize(@block, col = 0, row = 0)
      super(Key, col, row)
    end

    def self.key
      Key
    end

    def collidable?
      true
    end

    def draw(window : SF::RenderWindow)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(draw_size, draw_size)
      rect.fill_color = Color
      rect.outline_color = OutlineColor
      rect.outline_thickness = OutlineThickness
      rect.position = {x + draw_offset, y + draw_offset}

      window.draw(rect)
    end
  end

  class Block < BaseBlock
    Key = "block"

    def initialize(col = 0, row = 0)
      super(Key, col, row)
    end

    def self.key
      Key
    end
  end
end
