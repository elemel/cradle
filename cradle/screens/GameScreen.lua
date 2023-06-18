local Class = require("cradle.Class")
local heart = require("heart")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  self.engine = heart.newEngine()

  self.engine:addEvent("draw")
  self.engine:addEvent("keypressed")
  self.engine:addEvent("keyreleased")
  self.engine:addEvent("mousemoved")
  self.engine:addEvent("resize")
  self.engine:addEvent("update")
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
