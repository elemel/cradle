local GameScreen = require("cradle.screens.GameScreen")
local EditorScreen = require("cradle.screens.EditorScreen")
local MenuScreen = require("cradle.screens.MenuScreen")

local M = {}

function M.new(application)
  return MenuScreen.new(application, {
    title = "Cradle",
    options = {
      {
        title = "Play",
        handler = function()
          application:pushScreen(GameScreen.new(application))
        end,
      },

      {
        title = "Edit",
        handler = function()
          application:pushScreen(EditorScreen.new(application))
        end,
      },

      {
        title = "Toggle fullscreen",
        handler = function()
          love.window.setFullscreen(not love.window.getFullscreen())
        end,
      },

      {
        title = "Quit",
        handler = function()
          application:popScreen()
        end,
      },
    },
  })
end

return M
