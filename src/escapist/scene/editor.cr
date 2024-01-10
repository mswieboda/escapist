require "../room"
require "../floor_data"
require "../room_editor"

module Escapist::Scene
  class Editor < GSF::Scene
    getter view : View
    getter editor : RoomEditor
    getter floor_data : FloorData
    getter? menu
    getter menu_items
    getter? menu_rooms
    getter menu_room_items
    getter? menu_new

    TopBorder = 64
    BottomBorder = 64
    HorizontalBorder = 16

    RoomDimensionMin = 1
    RoomDimensionMax = 5

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

      @floor_data = FloorData.load
      @editor = RoomEditor.new(view, @floor_data.first_room)
      @menu = false
      @menu_items = GSF::MenuItems.new(Font.default)
      @menu_rooms = false
      @menu_room_items = GSF::MenuItems.new(Font.default)
      @menu_new = false
      @new_item_index = 0
      @new_items = [] of NewItem
    end

    def width
      Screen.width - HorizontalBorder * 2
    end

    def height
      Screen.height - TopBorder - BottomBorder
    end

    def open_menu
      @menu = true
      @menu_items = GSF::MenuItems.new(
        font: Font.default,
        size: 32,
        items: ["continue editing", "save room", "new room", "load room", "exit"],
        initial_focused_index: 0
      )
    end

    def update(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      if keys.just_pressed?(Keys::Escape)
        if menu_new?
          @menu_new = false
          open_menu
        elsif menu_rooms?
          @menu_rooms = false
          open_menu
        else
          open_menu if @menu = !@menu
        end
      end

      if menu?
        update_menu(frame_time, keys, mouse, joysticks)
      elsif menu_new?
        update_menu_new(keys)
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
          floor_data.update_room(editor.room)
          floor_data.save
          @menu = false
        when "new room"
          @new_item_index = 0
          @menu_new = true
          @menu = false
          @new_items = [
            NewItem.new("cols", 1),
            NewItem.new("rows", 1),
            NewItem.new("back")
          ]
        when "load room"
          items = [] of String | Tuple(String, String)

          floor_data.rooms.each do |id, room|
            items << {id, room.display_name}
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

    def update_menu_new(keys : Keys)
      item = @new_items[@new_item_index]

      update_menu_new_item_index(keys)
      update_menu_new_item_values(keys, item)
      update_menu_new_item_selection(keys, item)
    end

    def update_menu_new_item_index(keys : Keys)
      # next
      if keys.just_pressed?([Keys::Down, Keys::S, Keys::RShift, Keys::Tab])
        @new_item_index += 1
        @new_item_index = 0 if @new_item_index > @new_items.size - 1
      # prev
      elsif keys.just_pressed?([Keys::Up, Keys::W, Keys::LShift])
        @new_item_index -= 1
        @new_item_index = @new_items.size - 1 if @new_item_index < 0
      end
    end

    def update_menu_new_item_values(keys : Keys, item)
      if item.value?
        # value up
        if keys.just_pressed?([Keys::Right, Keys::D])
          item.increase
        # value down
        elsif keys.just_pressed?([Keys::Left, Keys::A])
          item.decrease
        end
      end
    end

    def update_menu_new_item_selection(keys : Keys, item)
      if keys.just_pressed?([Keys::Space, Keys::Enter])
        if item.value?
          if cols = @new_items.find { |i| i.key == "cols" }
            if rows = @new_items.find { |i| i.key == "rows" }
              @editor.room = Room.new(cols.data, rows.data)
              @menu_new = false
            end
          end
        elsif item.label == "back"
          @menu_new = false
          open_menu
        end
      end
    end

    def update_menu_rooms(frame_time, keys : Keys, mouse : Mouse, joysticks : Joysticks)
      menu_room_items.update(frame_time, keys, mouse)

      if menu_room_items.selected?(keys, mouse, joysticks)
        key = menu_room_items.focused_key

        if key == "back"
          @menu_rooms = false
          open_menu
          return
        end

        if found_room = floor_data.rooms[key]
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

      draw_menu_background(window) if menu? || menu_new? || menu_rooms?

      # NOTE: for now centered horizontally and vertically on the whole screen
      #       same as GSF::MenuItems placement
      size = 32
      x = Screen.width / 2
      y = Screen.height / 2 - size * 3

      if menu?
        draw_header_label(window, "editor", 48, x, y - 48 * 3)
        menu_items.draw(window)
      elsif menu_new?
        draw_header_label(window, "new room", 48, x, y - 48 * 3)
        draw_menu_new(window)
      elsif menu_rooms?
        draw_header_label(window, "load room", 48, x, y - 48 * 3)
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

    def draw_menu_new(window)
      # NOTE: for now centered horizontally and vertically on the whole screen
      #       same as GSF::MenuItems placement
      size = 32
      x = Screen.width / 2
      y = Screen.height / 2 - size * 3

      @new_items.each_with_index do |item, index|
        draw_new_selectable_label(window, item.label, size, index, x, y)
      end
    end

    def draw_header_label(window, label, size, x, y)
      text = SF::Text.new(label, Font.default, size)
      item_x = x - text.global_bounds.width / 2
      item_y = y - text.global_bounds.height / 2
      text.position = SF.vector2(item_x, item_y)
      text.fill_color = SF::Color::White

      window.draw(text)
    end

    def draw_new_selectable_label(window, label, size, index, x, y)
      text = SF::Text.new(label, Font.default, size)
      item_x = x - text.global_bounds.width / 2
      item_y = y - text.global_bounds.height / 2 + index * size * 2
      text.position = SF.vector2(item_x, item_y)

      # focused
      text.fill_color = @new_item_index == index ? SF::Color::Green : SF::Color::White

      window.draw(text)
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

  class NewItem
    @label : String

    getter data : Int32

    RoomDimensionMin = 1
    RoomDimensionMax = 5

    def initialize(@label, @data = 0)
    end

    def key
      @label
    end

    def value?
      @data > 0
    end

    def label
      value? ? "< #{@label}: #{@data} >" : @label
    end

    def increase
      @data += 1
      @data = RoomDimensionMax if @data > RoomDimensionMax
    end

    def decrease
      @data -= 1
      @data = RoomDimensionMin if @data < RoomDimensionMin
    end
  end
end
