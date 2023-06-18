local Class = require("cradle.Class")
local heart = require("heart")
local UpdateClockHandler = require("cradle.handlers.UpdateClockHandler")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  self.engine = heart.newEngine()

  self.engine:setProperty("clock", {
    fixedDt = 1 / 60,
    accumulatedDt = 0,
    maxAccumulatedDt = 0.1,
  })

  self.engine:addEvent("draw")
  self.engine:addEvent("fixedupdate")
  self.engine:addEvent("keypressed")
  self.engine:addEvent("keyreleased")
  self.engine:addEvent("mousemoved")
  self.engine:addEvent("resize")
  self.engine:addEvent("update")

  local world = love.physics.newWorld(0, 10)
  self.engine:setProperty("world", world)

  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
