require "json"

module Escapist
  class RoomData
    include JSON::Serializable

    getter rooms : Array(Room)

    FilePath = "./assets/room_data.dat"

    def initialize
      @rooms = [] of Room
    end

    def update_room(room)
      # TODO: add prompt to confirm overwrite, for now, always overwrite
      if found_room = rooms.find { |r| r.id == room.id }
        rooms.delete(found_room)
      end

      @rooms << room
    end

    def remove_room(id)
      if room = rooms.find { |r| r.id == id }
        rooms.delete(room)
      end
    end

    def save
      File.write(FilePath, to_json)
    end

    def self.load
      if File.exists?(FilePath)
        self.from_json(File.read(FilePath))
      else
        room = RoomData.new
        room.save
        room
      end
    end
  end
end
