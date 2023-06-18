local Class = require("cradle.Class")
local DrawWorldHandler = require("cradle.handlers.DrawWorldHandler")
local heart = require("heart")
local KeyPressedHandler = require("cradle.handlers.KeyPressedHandler")
local UpdateClockHandler = require("cradle.handlers.UpdateClockHandler")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  self.engine = heart.newEngine()
  self.engine:setProperty("application", application)

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

  local body = love.physics.newBody(world)
  local shape = love.physics.newCircleShape(0.5)
  local fixture = love.physics.newFixture(body, shape)

  self.engine:addEventHandler("draw", DrawWorldHandler.new(self.engine))
  self.engine:addEventHandler("keypressed", KeyPressedHandler.new(self.engine))
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
