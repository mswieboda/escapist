require "game_sf"

require "./escapist/game"

module Escapist
  alias Keys = GSF::Keys
  alias Mouse = GSF::Mouse
  alias Joysticks = GSF::Joysticks
  alias Screen = GSF::Screen
  alias Timer = GSF::Timer
  alias View = GSF::View

  Game.new.run
end
