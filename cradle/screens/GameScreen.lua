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
local FixedUpdateDeletingBodyHandler =
  require("cradle.handlers.FixedUpdateDeletingBodyHandler")
local FixedUpdateDeletingFixtureHandler =
  require("cradle.handlers.FixedUpdateDeletingFixtureHandler")
local FixedUpdateDeletingHandler =
  require("cradle.handlers.FixedUpdateDeletingHandler")
local FixedUpdateDeletingJointHandler =
  require("cradle.handlers.FixedUpdateDeletingJointHandler")
local FixedUpdateInputHandler =
  require("cradle.handlers.FixedUpdateInputHandler")
local FixedUpdateRiderHandler =
  require("cradle.handlers.FixedUpdateRiderHandler")
local FixedUpdateWorldHandler =
  require("cradle.handlers.FixedUpdateWorldHandler")
local heart = require("heart")
local motorcycleMod = require("cradle.motorcycle")
local nodeMod = require("cradle.node")
local KeyPressedHandler = require("cradle.handlers.KeyPressedHandler")
local riderMod = require("cradle.rider")
local sparrow = require("sparrow")
local UpdateClockHandler = require("cradle.handlers.UpdateClockHandler")

local M = Class.new()

function M:init(application)
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
  database:createColumn("camera", "tag")
  database:createColumn("creating", "tag")
  database:createColumn("deleting", "tag")
  database:createColumn("dynamic", "tag")
  database:createColumn("externalBody")
  database:createColumn("externalFixture")
  database:createColumn("externalJoint")
  database:createColumn("fixture")
  database:createColumn("joint")
  database:createColumn("kinematic", "tag")
  database:createColumn("localTransform", "transform")
  database:createColumn("motorcycle", "tag")
  database:createColumn("node", "node")
  database:createColumn("position", "vec2")
  database:createColumn("rider", "tag")
  database:createColumn("shape")
  database:createColumn("static", "tag")
  database:createColumn("transform", "transform")

  self.engine:addEvent("draw")
  self.engine:addEvent("fixedupdate")
  self.engine:addEvent("keypressed")
  self.engine:addEvent("keyreleased")
  self.engine:addEvent("mousemoved")
  self.engine:addEvent("resize")
  self.engine:addEvent("update")

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
    FixedUpdateDeletingJointHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDeletingFixtureHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDeletingBodyHandler.new(self.engine)
  )

  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateDeletingHandler.new(self.engine)
  )

  self.engine:addEventHandler("keypressed", KeyPressedHandler.new(self.engine))
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0, 0.5 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {},
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    localTransform = {
      rotation = { math.cos(-0.5), math.sin(-0.5) },
      translation = { 4, -0.5 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {},
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    localTransform = {
      rotation = { math.cos(0.5), math.sin(0.5) },
      translation = { 15, -0.5 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {},
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 19, 0.5 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {},
  })

  local frameEntity = motorcycleMod.createMotorcycle(database, {
    rotation = { 1, 0 },
    translation = { 0, -0.45 },
  })

  local trunkEntity = riderMod.createRider(database, frameEntity, {
    rotation = { 1, 0 },
    translation = { 0, -0.6 },
  })

  database:insertRow({
    camera = {},

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0.65, 0.3 },
    },

    transform = {},
  })
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
