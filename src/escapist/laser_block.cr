require "./movable_block"

module Escapist
  def self.rotate_vector(vector, angle)
    radians = Math::PI * angle / 180.0
    cos = Math.cos(radians)
    sin = Math.sin(radians)

    {
      x: vector[:x] * cos - vector[:y] * sin,
      y: vector[:x] * sin + vector[:y] * cos
    }
  end

  alias LaserInfo = NamedTuple(
    x: Float32,
    y: Float32,
    rotation_angle: Float32,
    distance: Float32,
    end_x: Float32,
    end_y: Float32
  )

  class LaserBlock < MovableBlock
    @[JSON::Field(ignore: true)]
    getter rotation_angle : Float32 | Int32 = 0

    @[JSON::Field(ignore: true)]
    getter? rotating = false

    @[JSON::Field(ignore: true)]
    @rotatable = false

    @[JSON::Field(ignore: true)]
    @rotate_to : Float32 | Int32 = 0

    @[JSON::Field(ignore: true)]
    @rotating_direction : Int32 = 1

    @[JSON::Field(ignore: true)]
    getter lasers : Array(LaserInfo) = [] of LaserInfo

    Key = "laser"
    LaserBarrelColorFilled = SF::Color.new(51, 51, 51)
    LaserBarrelColor = SF::Color.new(153, 0, 0, 51)
    LaserBarrelOutlineColor = SF::Color.new(153, 0, 0, 153)
    LaserBarrelOutlineThickness = 3
    LaserCenterWidth = 4
    LaserCenterColor = SF::Color.new(153, 0, 0, 153)
    LaserCenterOutlineColor = SF::Color.new(102, 0, 0, 102)
    LaserCenterOutlineThickness = 2
    LaserWidth = 16
    LaserColor = SF::Color.new(102, 0, 0, 102)
    LaserOutlineColor = SF::Color.new(153, 0, 0, 51)
    LaserOutlineThickness = 4
    RotatableIndicatorOutlineColor = SF::Color.new(153, 0, 0, 153)
    RotatableIndicatorOutlineThickness = 6

    RotationSpeed = 90
    RotationAmount = 45

    def initialize(col = 0, row = 0)
      @rotation_angle = 0
      @rotatable = false
      @rotate_to = 0
      @rotating_direction = 1
      @rotating = false
      @lasers = [] of LaserInfo

      super(col, row)
    end

    def self.key
      Key
    end

    def area?
      true
    end

    def area_box
      Box.new(
        (x - size / 8).to_f32,
        (y - size / 8).to_f32,
        (size + size / 4).to_f32
      )
    end

    def area_entered
      @rotatable = true
    end

    def area_exited
      @rotatable = false
    end

    def area_entered?
      @rotatable
    end

    def rotatable?
      @rotatable && !rotating?
    end

    def rotate(direction = 1)
      @rotating = true
      @rotating_direction = direction
      @rotate_to = rotation_angle + direction * RotationAmount
    end

    def rotate_reverse
      rotate(-1)
    end

    def update(frame_time, room)
      update_rotation(frame_time) if rotating?
      update_laser_distance(room)
    end

    def update_rotation(frame_time)
      @rotation_angle += frame_time * @rotating_direction * RotationSpeed

      if done_rotating?
        @rotation_angle = @rotate_to

        if @rotating_direction > 0
          @rotation_angle -= 360 if @rotation_angle >= 360
        else
          @rotation_angle += 360 if @rotation_angle <= -360
        end

        @rotating = false
      end
    end

    def done_rotating?
      @rotating_direction > 0 && @rotation_angle >= @rotate_to ||
        @rotating_direction < 0 && @rotation_angle <= @rotate_to
    end

    def update_laser_distance(room)
      start_point = {x: x + size / 2, y: y + size / 2}
      direction = {x: 0, y: -1}
      direction = Escapist.rotate_vector(direction, rotation_angle)
      distance = cast_ray(start_point, direction, room)

      radians = Math::PI * rotation_angle / 180.0
      end_x = start_point[:x] + Math.sin(radians) * distance
      end_y = start_point[:y] - Math.cos(radians) * distance

      @lasers = [
        {
          x: start_point[:x].to_f32,
          y: start_point[:y].to_f32,
          rotation_angle: rotation_angle.to_f32,
          distance: distance.to_f32,
          end_x: end_x.to_f32,
          end_y: end_y.to_f32
        }
      ]
    end

    def cast_ray(start_point, direction, room)
      x, y = start_point[:x], start_point[:y]
      dx, dy = direction[:x], direction[:y]

      distance = 0

      loop do
        row = (x / room.tile_size).to_i
        col = (y / room.tile_size).to_i

        break if laser_switch_found?(row, col, room, start_point[:x], start_point[:y], distance)
        break if tile_found?(row, col, room)

        # no tile_objs, check room bounds
        break if x < 0 || y < 0 || row >= room.rows || col >= room.cols

        distance += 1
        x += dx
        y += dy
      end

      distance
    end

    def tile_found?(row, col, room)
      tile_obj_found = nil

      if room.tiles.has_key?(row) && room.tiles[row].has_key?(col)
        tile_obj_found = room.tiles[row][col]
      end

      if tile_obj = tile_obj_found
        if tile_obj != self && tile_obj.collidable? && !tile_obj.is_a?(LaserSwitch)
          return true
        end
      end

      false
    end

    def laser_switch_found?(row, col, room, x, y, distance)
      tile_obj = nil

      if room.tiles.has_key?(row) && room.tiles[row].has_key?(col)
        tile_obj = room.tiles[row][col]
      end

      if tile_obj.is_a?(LaserSwitch)
        if laser_switch = tile_obj.as(LaserSwitch)
          return laser_switch_collision?(laser_switch, x, y, distance)
        end
      end

      false
    end

    def laser_switch_collision?(laser_switch : LaserSwitch, x, y, distance)
      radians = Math::PI * rotation_angle / 180.0
      laser_point_x = x + Math.sin(radians) * distance
      laser_point_y = y - Math.cos(radians) * distance

      laser_switch.laser_point_collision?(laser_point_x, laser_point_y)
    end

    def draw_movable(window : SF::RenderWindow)
      draw_laser_barrel(window)
      draw_rotatable_indicator(window) if rotatable?
      draw_lasers(window)
    end

    def draw_laser_barrel(window)
      tri_size = size / 8

      # barrel filled, to make opaque
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.rotation = rotation_angle
      tri.fill_color = LaserBarrelColorFilled
      tri.position = {
        x + size / 2,
        y + size / 2,
      }
      window.draw(tri)

      # barrel with laser filling and outline
      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.rotation = rotation_angle
      tri.fill_color = LaserBarrelColor
      tri.outline_color = LaserBarrelOutlineColor
      tri.outline_thickness = LaserBarrelOutlineThickness
      tri.position = {
        x + size / 2,
        y + size / 2
      }
      window.draw(tri)
    end

    def draw_rotatable_indicator(window)
      circle_size = size / 4

      circle = SF::CircleShape.new(circle_size)
      circle.origin = {circle_size, circle_size}
      circle.fill_color = SF::Color::Transparent
      circle.outline_color = RotatableIndicatorOutlineColor
      circle.outline_thickness = RotatableIndicatorOutlineThickness
      circle.position = {
        x + size / 2,
        y + size / 2
      }

      window.draw(circle)

      # arrows to indicate rotation, around circle
      tri_size = size / 8

      tri = SF::CircleShape.new(tri_size, 3)
      tri.origin = {tri_size, tri_size}
      tri.fill_color = RotatableIndicatorOutlineColor
      tri.rotation = 90
      tri.position = {
        x + circle_size * 2,
        y + circle_size
      }
      window.draw(tri)

      tri.rotation = 180
      tri.position = {
        x + circle_size * 3,
        y + circle_size * 2
      }
      window.draw(tri)

      tri.rotation = 270
      tri.position = {
        x + circle_size * 2,
        y + circle_size * 3
      }
      window.draw(tri)

      tri.rotation = 0
      tri.position = {
        x + circle_size,
        y + circle_size * 2
      }
      window.draw(tri)
    end

    def draw_lasers(window)
      lasers.each do |laser|
        draw_laser(window, laser)
      end
    end

    def draw_laser(window, laser)
      # center laser
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(LaserCenterWidth, laser[:distance])
      rect.origin = {
        LaserCenterWidth / 2,
        laser[:distance]
      }
      rect.rotation = laser[:rotation_angle]
      rect.fill_color = LaserCenterColor
      rect.outline_color = LaserCenterOutlineColor
      rect.outline_thickness = LaserCenterOutlineThickness
      rect.position = {laser[:x], laser[:y]}

      window.draw(rect)

      # main laser
      rect = SF::RectangleShape.new
      rect.size = SF.vector2f(LaserWidth, laser[:distance])
      rect.origin = {
        LaserWidth / 2,
        laser[:distance]
      }
      rect.rotation = laser[:rotation_angle]
      rect.fill_color = LaserColor
      rect.outline_color = LaserOutlineColor
      rect.outline_thickness = LaserOutlineThickness
      rect.position = {laser[:x], laser[:y]}

      window.draw(rect)
    end
  end
end
