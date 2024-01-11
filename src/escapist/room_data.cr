require "json"

module Escapist
  class RoomData
    include JSON::Serializable

    getter rooms : Hash(String, Room)
    getter first_room_key : String = ""

    FilePath = "./assets/room_data.dat"

    def initialize
      @rooms = Hash(String, Room).new
      room = Room.new(1, 1)
      @first_room_key = room.id
      @rooms[@first_room_key] = room
    end

    def first_room
      @rooms[@first_room_key]
    end

    def update_room(room)
      @first_room_key = room.id if first_room_key.empty?

      # TODO: add prompt to confirm overwrite, for now, always overwrite
      @rooms[room.id] = room
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
