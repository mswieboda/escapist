require "./tile_obj"

module Escapist
  abstract class Switch < TileObj
    Key = "sw"

    property? on

    def initialize(col = 0, row = 0, @on = false)
      super(col, row)
    end

    def self.key
      Key
    end
  end
end
