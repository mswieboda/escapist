module Escapist
  class FloorData
    FirstRoomKey = "start"
    MAX_ROOM_SIZE = 5

    getter room_data : RoomData
    getter rooms : Hash(String, Room)
    getter grid : Array(Array(String))

    def initialize
      @room_data = RoomData.load
      @rooms = Hash(String, Room).new
      @grid = [] of Array(String)

      # add first room
      room = Room.new(1, 1, first_room_key)
      @rooms[room.key] = room
      @grid << [room.key]

      generate(first_room_key)
    end

    def self.first_room_key
      FirstRoomKey
    end

    def first_room_key
      self.class.first_room_key
    end

    def generate(from_room_key)
      return if rooms.size >= MAX_ROOM_SIZE

      from_room = rooms[from_room_key]
      row_index = rand(1..from_room.s_rows) - 1
      col_index = rand(1..from_room.s_cols) - 1

      # TODO: randomize this from RoomData.rooms
      next_room = Room.new(rand(1..3), rand(1..3))

      if add_room(row_index, col_index, DoorConfig.sample, from_room, next_room)
        rooms[next_room.key] = next_room

        generate(next_room.key)
      else
        generate(from_room_key)
      end
    end

    def add_room(row_index, col_index, door : DoorConfig, from_room : Room, room : Room)
      new_row_index = row_index + door.drow
      new_col_index = col_index + door.dcol
      door_section_index = door.drow.abs > 0 ? rand(room.s_cols) : rand(room.s_rows)

      previous_grid = grid.dup

      # puts ">>> add_room #{[new_row_index, new_col_index]} #{{door_section_index: door_section_index, door: door.name, room: [room.s_rows, room.s_cols]}}"

      rows_to_insert, cols_to_insert = resize_grid(
        new_row_index, new_col_index, door_section_index, door, room
      )

      room_r_index, room_c_index = room_indexes(
        new_row_index, new_col_index, rows_to_insert, cols_to_insert,
        door_section_index, door
      )

      if room_collision?(room_r_index, room_c_index, room)
        # put grid back before insert/add
        grid = previous_grid

        return false
      end

      set_grid_room_keys(
        new_row_index, new_col_index, rows_to_insert, cols_to_insert,
        door_section_index, door, room
      )

      set_doors(row_index, col_index, door, door_section_index, from_room, room)

      true
    end

    def room_indexes(r_index, c_index, r_insert, c_insert, door_section_index, door)
      room_r_index = r_insert > 0 ? 0 : r_index
      room_c_index = c_insert > 0 ? 0 : c_index

      # apply door_section_index
      room_r_index -= door_section_index if door.dcol.abs > 0
      room_c_index -= door_section_index if door.drow.abs > 0

      {room_r_index, room_c_index}
    end

    def room_collision?(room_r_index, room_c_index, room)
      room.s_rows.times do |s_row_i|
        grid_row_index = room_r_index + s_row_i
        row = grid[grid_row_index]

        room.s_cols.times do |s_col_i|
          grid_col_index = room_c_index + s_col_i

          return true if row[grid_col_index] != ""
        end
      end

      false
    end

    def resize_grid(new_row_index, new_col_index, door_section_index, door, room)
      rows_to_insert = insert_rows(new_row_index, door_section_index, door, room)
      add_rows(new_row_index, door_section_index, door, room)

      cols_to_insert = insert_cols(new_col_index, door_section_index, door, room)
      add_cols(new_col_index, door_section_index, door, room)

      {rows_to_insert, cols_to_insert}
    end

    def insert_rows(new_row_index, door_section_index, door, room)
      via_drow = door.drow < 0 ? room.s_rows - 1 : 0
      via_dcol = door.dcol.abs > 0 ? door_section_index : 0
      rows_to_insert = -new_row_index + via_drow + via_dcol

      return 0 unless rows_to_insert > 0

      rows_to_insert.times do
        grid.insert(0, grid[0].size.times.to_a.map { "" })
      end

      rows_to_insert
    end

    def add_rows(new_row_index, door_section_index, door, room)
      via_drow = door.drow > 0 ? room.s_rows - 1 : 0
      via_dcol = door.dcol.abs > 0 ? room.s_rows - door_section_index - 1 : 0
      via_door_index = door.dcol.abs > 0 ? door_section_index : 0
      rows_to_add = new_row_index + via_drow + via_dcol + via_door_index - (grid.size - 1)

      return 0 unless rows_to_add > 0

      rows_to_add.times do
        grid << grid[0].size.times.to_a.map { "" }
      end

      rows_to_add
    end

    def insert_cols(new_col_index, door_section_index, door, room)
      via_drow = door.drow.abs > 0 ? door_section_index : 0
      via_dcol = door.dcol < 0 ? room.s_cols - 1 : 0
      cols_to_insert = -new_col_index + via_drow + via_dcol

      return 0 unless cols_to_insert > 0

      grid.each do |row|
        cols_to_insert.times do
          row.insert(0, "")
        end
      end

      cols_to_insert
    end

    def add_cols(new_col_index, door_section_index, door, room)
      via_drow = door.drow.abs > 0 ? room.s_cols - door_section_index - 1 : 0
      via_dcol = door.dcol > 0 ? room.s_cols - 1 : 0
      via_door_index = door.drow.abs > 0 ? door_section_index : 0
      cols_to_add = new_col_index + via_drow + via_dcol + via_door_index - (grid[0].size - 1)

      return 0 unless cols_to_add > 0

      grid.each do |row|
        cols_to_add.times do
          row << ""
        end
      end

      cols_to_add
    end

    def set_grid_room_keys(
      new_row_index, new_col_index, rows_to_insert, cols_to_insert,
      door_section_index, door, room
    )
      room_r_index = rows_to_insert > 0 ? 0 : new_row_index
      room_c_index = cols_to_insert > 0 ? 0 : new_col_index

      # apply door_section_index
      room_r_index -= door_section_index if door.dcol.abs > 0
      room_c_index -= door_section_index if door.drow.abs > 0

      # puts ">>> set_grid_room_keys #{[room_r_index, room_c_index]}"

      room.s_rows.times do |s_row_i|
        grid_row_index = room_r_index + s_row_i
        row = grid[grid_row_index]

        room.s_cols.times do |s_col_i|
          grid_col_index = room_c_index + s_col_i

          unless row[grid_col_index] == ""
            puts "Error: room collision at [#{grid_row_index}, #{grid_col_index}]"
            break
          end

          row[grid_col_index] = room.key
        end
      end
    end

    def set_doors(row_index, col_index, door, door_section_index, from_room, room)
      doors, from_door_section_index = doors_door_section_index(
        door.name, from_room, row_index, col_index
      )

      add_empty_doors(doors, from_door_section_index)

      doors[from_door_section_index] = room.key

      doors, _ = doors_door_section_index(door.opposite, room)

      add_empty_doors(doors, door_section_index)

      doors[door_section_index] = from_room.key
    end

    def doors_door_section_index(door_name, room, col_index = 0, row_index = 0)
      case door_name
      when :top
        {room.doors.top, col_index}
      when :left
        {room.doors.left, row_index}
      when :bottom
        {room.doors.bottom, col_index}
      when :right
        {room.doors.right, row_index}
      else
        {room.doors.top, col_index}
      end
    end

    def add_empty_doors(doors, door_section_index)
      if doors.size - 1 < door_section_index
        (door_section_index + 1 - doors.size).times do
          doors << nil
        end
      end
    end

    def display_grid
      puts grid
      grid.each do |row|
        puts row.map { |c| c == "" ? "X" : c[0] }.join
      end
    end
  end

  struct DoorConfig
    # @@values : Array(DoorConfig)?
    Top = DoorConfig.new(:top, -1_i8, 0_i8, :bottom, :right)
    Left = DoorConfig.new(:left, 0_i8, -1_i8, :right, :top)
    Bottom = DoorConfig.new(:bottom, 1_i8, 0_i8, :top, :left)
    Right = DoorConfig.new(:right, 0_i8, 1_i8, :left, :bottom)
    All = [Top, Left, Bottom, Right]

    getter name : Symbol
    getter drow : Int8
    getter dcol : Int8
    getter opposite : Symbol
    getter clockwise : Symbol

    def initialize(@name, @drow, @dcol, @opposite, @clockwise)
    end

    def self.values
      All
    end

    def self.sample
      values.sample
    end

    def self.top
      Top
    end

    def self.left
      Left
    end

    def self.bottom
      Bottom
    end

    def self.right
      Right
    end
  end
end
