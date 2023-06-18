local Class = require("cradle.Class")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
end

function M:handleEvent(event, ...)
  if event ~= "quit" then
    love.event.quit()
  end
end

return M
