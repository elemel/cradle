local Class = require("cradle.Class")

local insert = assert(table.insert)
local remove = assert(table.remove)

local M = Class.new()

function M:init()
  self._screens = {}
  -- self._fontFilename = "resources/fonts/gothica-book.ttf"
  self._fonts = {}
end

function M:getFont(size)
  size = size or 12

  if self._fonts[size] == nil then
    -- self._fonts[size] = love.graphics.newFont(self._fontFilename, size)
    self._fonts[size] = love.graphics.newFont(size)
  end

  return self._fonts[size]
end

function M:peekScreen()
  return self._screens[#self._screens]
end

function M:pushScreen(screen)
  insert(self._screens, screen)
end

function M:popScreen()
  return remove(self._screens)
end

function M:handleEvent(event, ...)
  local screen = self:peekScreen()

  if screen then
    screen:handleEvent(event, ...)
  end
end

return M
