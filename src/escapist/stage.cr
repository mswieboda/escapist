require "./scene/start"
require "./scene/main"
require "./scene/editor"

module Escapist
  class Stage < GSF::Stage
    getter start

    def initialize(window : SF::RenderWindow)
      super(window)

      @start = Scene::Start.new
      @scene = start
    end

    def check_scenes
      if scene.exit?
        if scene.name == :start
          @exit = true
        else
          switch(start)
        end

        return
      end

      if scene.name == :start
        if start_scene = start.start_scene
          switch_via_key(start_scene)
        end
      end
    end

    def switch_via_key(key)
      case key
      when :main
        switch(Scene::Main.new(window))
      when :editor
        switch(Scene::Editor.new(window))
      end
    end
  end
end
