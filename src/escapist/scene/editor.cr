require "../room"
require "../room_data"
require "../room_editor"

module Escapist::Scene
  class Editor < GSF::Scene
    getter view : View
    getter editor : RoomEditor
    getter room_data : RoomData
    getter? menu
    getter menu_items
    getter? menu_rooms
    getter menu_room_items

    TopBorder = 64
    BottomBorder = 64
    HorizontalBorder = 16

    def initialize(window)
      super(:editor)

      @view = View.from_default(window).dup

      view.reset(HorizontalBorder, TopBorder, width, height)
      view.zoom(1 / Screen.scaling_factor)
      view.viewport(
        x: HorizontalBorder / Screen.width,
        y: TopBorder / Screen.height,
        width: width / Screen.width,
        height: height / Screen.height
      )

      @room_data = RoomData.load
      @editor = RoomEditor.new(view, Room.new(3, 2))
      @menu = false
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        size: 32,
        items: ["continue editing", "save room", "new room", "load room", "exit"],
        initial_focused_index: 0
      )
      @menu_room_items = GSF::MenuItems.new(Font.default)
    end

    def width
      Screen.width - HorizontalBorder * 2
    end

    def height
      Screen.height - TopBorder - BottomBorder
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        if menu_rooms?
          @menu_rooms = false
          @menu = true
        else
          @menu = !@menu
        end
      end

      if menu?
        update_menu(frame_time, keys, mouse, joysticks)
      elsif menu_rooms?
        update_menu_rooms(frame_time, keys, mouse, joysticks)
      else
        editor.update(frame_time, keys)
      end
    end

    def update_menu(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_items.update(frame_time, keys, mouse)

      if menu_items.selected?(keys, mouse, joysticks)
        case menu_items.focused_label
        when "continue editing"
          @menu = false
        when "save room"
          @room_data.update_room(editor.room)
          @room_data.save
          @menu = false
        when "new room"
          # TODO: make s_cols, s_rows editable
          @editor.room = Room.new(1, 1)
          @menu = false
        when "load room"
          items = [] of String | Tuple(String, String)

          @room_data.rooms.each do |room|
            items << {room.id, room.display_name}
          end

          items << "back"

          @menu_room_items = GSF::MenuItems.new(
            font: Font.default,
            size: 32,
            items: items,
            initial_focused_index: 0
          )

          @menu_rooms = true
          @menu = false
        when "exit"
          @menu = false
          @exit = true
        end
      end
    end

    def update_menu_rooms(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_room_items.update(frame_time, keys, mouse)

      if menu_room_items.selected?(keys, mouse, joysticks)
        key = menu_room_items.focused_key

        if key == "back"
          @menu_rooms = false
          @menu = true
          return
        end

        if found_room = @room_data.rooms.find { |room| room.id == key }
          @editor.room = found_room
          @menu_rooms = false
        else
          puts "Error: room \"#{key}\" not found in room data"
        end
      end
    end

    def draw(window)
      view.set_current

      editor.draw(window)

      view.set_default_current

      draw_border(window)

      draw_menu_background(window)  if menu? || menu_rooms?

      if menu?
        menu_items.draw(window)
      elsif menu_rooms?
        menu_room_items.draw(window)
      end
    end

    def draw_menu_background(window)
      menu_width = width / 2
      menu_height = height / 1.5

      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(menu_width, menu_height)
      rect.fill_color = SF::Color::Black
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {HorizontalBorder + width / 2 - menu_width / 2, TopBorder + height / 2 - menu_height / 2}

      window.draw(rect)
    end

    def draw_border(window)
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(width, height)
      rect.fill_color = SF::Color::Transparent
      rect.outline_color = SF::Color.new(33, 33, 33)
      rect.outline_thickness = 3
      rect.position = {HorizontalBorder, TopBorder}

      window.draw(rect)
    end
  end
end
