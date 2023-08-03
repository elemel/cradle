local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local DrawWorldHandler = require("cradle.handlers.DrawWorldHandler")
local FixedUpdateCameraHandler =
  require("cradle.handlers.FixedUpdateCameraHandler")
local FixedUpdateCreatingBodyHandler =
  require("cradle.handlers.FixedUpdateCreatingBodyHandler")
local FixedUpdateCreatingFixtureHandler =
  require("cradle.handlers.FixedUpdateCreatingFixtureHandler")
local FixedUpdateCreatingHandler =
  require("cradle.handlers.FixedUpdateCreatingHandler")
local FixedUpdateCreatingJointHandler =
  require("cradle.handlers.FixedUpdateCreatingJointHandler")
local FixedUpdateCreatingTransformHandler =
  require("cradle.handlers.FixedUpdateCreatingTransformHandler")
local FixedUpdateDestroyingBodyHandler =
  require("cradle.handlers.FixedUpdateDestroyingBodyHandler")
local FixedUpdateDestroyingFixtureHandler =
  require("cradle.handlers.FixedUpdateDestroyingFixtureHandler")
local FixedUpdateDestroyingHandler =
  require("cradle.handlers.FixedUpdateDestroyingHandler")
local FixedUpdateDestroyingJointHandler =
  require("cradle.handlers.FixedUpdateDestroyingJointHandler")
local FixedUpdateInputHandler =
  require("cradle.handlers.FixedUpdateInputHandler")
local FixedUpdateRiderHandler =
  require("cradle.handlers.FixedUpdateRiderHandler")
local FixedUpdateWorldHandler =
  require("cradle.handlers.FixedUpdateWorldHandler")
local heart = require("heart")
local jsonMod = require("json")
local motorcycleMod = require("cradle.motorcycle")
local nodeMod = require("cradle.node")
local KeyPressedHandler = require("cradle.handlers.KeyPressedHandler")
local MouseMovedHandler = require("cradle.handlers.MouseMovedHandler")
local riderMod = require("cradle.rider")
local sparrow = require("sparrow")
local UpdateClockHandler = require("cradle.handlers.UpdateClockHandler")

local M = Class.new()

function M:init(application, config)
  config = config or {}
  local demo = config.demo or false

  love.mouse.setRelativeMode(true)

  self.application = assert(application)
  self.engine = heart.newEngine()
  self.engine:setProperty("application", application)

  self.engine:setProperty("clock", {
    accumulatedDt = 0,
    fixedDt = 1 / 60,
    fixedFrame = 0,
    frame = 0,
    maxAccumulatedDt = 0.1,
  })

  local database = sparrow.newDatabase()
  self.engine:setProperty("database", database)

  database:createColumn("body")
  database:createColumn("bodyConfig")
  database:createColumn("camera", "tag")
  database:createColumn("creating", "tag")
  database:createColumn("destroying", "tag")
  database:createColumn("dynamic", "tag")
  database:createColumn("fixture")
  database:createColumn("fixtureConfig")
  database:createColumn("joint")
  database:createColumn("jointConfig")
  database:createColumn("kinematic", "tag")
  database:createColumn("localTransform", "transform")
  database:createColumn("motorcycle", "tag")
  database:createColumn("node", "node")
  database:createColumn("position", "vec2")
  database:createColumn("rider", "tag")
  database:createColumn("shapeConfig")
  database:createColumn("spring")
  database:createColumn("static", "tag")
  database:createColumn("transform", "transform")
  database:createColumn("wheel", "tag")

  if not demo then
    local json = love.filesystem.read("database.json")
    local rows = jsonMod.decode(json)

    for entity, row in pairs(rows) do
      database:insertRow(row, entity)
    end
  end

  self.engine:addEvent("draw")
  self.engine:addEvent("fixedupdate")
  self.engine:addEvent("keypressed")
  self.engine:addEvent("keyreleased")
  self.engine:addEvent("mousemoved")
  self.engine:addEvent("mousepressed")
  self.engine:addEvent("mousereleased")
  self.engine:addEvent("resize")
  self.engine:addEvent("textinput")
  self.engine:addEvent("update")
  self.engine:addEvent("wheelmoved")

  local world = love.physics.newWorld(0, 10)
  self.engine:setProperty("world", world)

  self.engine:addEventHandler("draw", DrawWorldHandler.new(self.engine))

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreatingTransformHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreatingBodyHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreatingFixtureHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreatingJointHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreatingHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateInputHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateRiderHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateWorldHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCameraHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDestroyingJointHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDestroyingFixtureHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDestroyingBodyHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDestroyingHandler.new(self.engine)
  )

  self.engine:addEventHandler("keypressed", KeyPressedHandler.new(self.engine))
  self.engine:addEventHandler("mousemoved", MouseMovedHandler.new(self.engine))
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))

  if demo then
    database:insertRow({
      bodyConfig = {},
      creating = {},

      fixtureConfig = {
        friction = 0.5,
      },

      localTransform = {
        orientation = { 1, 0 },
        position = { 0, 0.5 },
      },

      node = {},

      shapeConfig = {
        shapeType = "rectangle",
        size = { 5, 1 },
      },

      transform = {},
    })

    database:insertRow({
      bodyConfig = {},
      creating = {},

      fixtureConfig = {
        friction = 0.5,
      },

      localTransform = {
        orientation = { math.cos(-0.5), math.sin(-0.5) },
        position = { 4, -0.5 },
      },

      node = {},

      shapeConfig = {
        shapeType = "rectangle",
        size = { 5, 1 },
      },

      transform = {},
    })

    database:insertRow({
      bodyConfig = {},
      creating = {},

      fixtureConfig = {
        friction = 0.5,
      },

      localTransform = {
        orientation = { math.cos(0.5), math.sin(0.5) },
        position = { 15, -0.5 },
      },

      node = {},

      shapeConfig = {
        shapeType = "rectangle",
        size = { 5, 1 },
      },

      transform = {},
    })

    database:insertRow({
      bodyConfig = {},
      creating = {},

      fixtureConfig = {
        friction = 0.5,
      },

      localTransform = {
        orientation = { 1, 0 },
        position = { 19, 0.5 },
      },

      node = {},

      shapeConfig = {
        shapeType = "rectangle",
        size = { 5, 1 },
      },

      transform = {},
    })

    local frameEntity = motorcycleMod.createMotorcycle(database, {
      orientation = { 1, 0 },
      position = { 0, -0.45 },
    })

    local trunkEntity = riderMod.createRider(database, frameEntity, {
      orientation = { 1, 0 },
      position = { 0, -0.6 },
    })

    database:insertRow({
      camera = {},

      localTransform = {
        orientation = { 1, 0 },
        position = { 0.65, 0.3 },
      },

      transform = {},
    })
  end
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
