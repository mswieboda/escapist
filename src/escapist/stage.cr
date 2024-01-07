require "./scene/start"
require "./scene/main"
require "./scene/editor"

module Escapist
  class Stage < GSF::Stage
    getter start
    getter main
    getter editor

    def initialize(window : SF::RenderWindow)
      super(window)

      @start = Scene::Start.new
      @main = Scene::Main.new(window)
      @editor = Scene::Editor.new(window)

      @scene = start
    end

    def check_scenes
      case scene.name
      when :start
        if scene.exit?
          @exit = true
        elsif start_scene = start.start_scene
          switch(main) if start_scene == :main
          switch(editor) if start_scene == :editor
        end
      when :main, :editor
        switch(start) if scene.exit?
      end
    end
  end
end
