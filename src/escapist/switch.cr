require "./tile_obj"

module Escapist
  abstract class Switch < TileObj
    Key = "switch"

    use_json_discriminator "switch", {floor: FloorSwitch}

    property switch : String
    property? on

    def initialize(@switch, col = 0, row = 0, @on = false)
      super(Key, col, row)
    end

    def self.key
      Key
    end
  end
end
