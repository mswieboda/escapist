require "json"

module Escapist
  class RoomData
    include JSON::Serializable

    getter rooms : Hash(String, Room)

    FilePath = "./assets/room_data.dat"

    def initialize
      room = Room.new(1, 1)
      @rooms = Hash(String, Room).new
      @rooms[room.key] = room
    end

    def update_room(room)
      # TODO: add prompt to confirm overwrite, for now, always overwrite
      @rooms[room.key] = room
    end

    def remove_room(id)
      rooms.delete(room) if rooms.has_key?(id)
    end

    def save
      File.write(FilePath, to_json)
    end

    def self.load
      if File.exists?(FilePath)
        self.from_json(File.read(FilePath))
      else
        data = self.new
        data.save
        data
      end
    end
  end
end
