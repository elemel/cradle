local Class = require("cradle.Class")
local DrawWorldHandler = require("cradle.handlers.DrawWorldHandler")
local ffi = require("ffi")
local FixedUpdateCreatingBodyHandler =
  require("cradle.handlers.FixedUpdateCreatingBodyHandler")
local FixedUpdateCreatingFixtureHandler =
  require("cradle.handlers.FixedUpdateCreatingFixtureHandler")
local FixedUpdateCreatingHandler =
  require("cradle.handlers.FixedUpdateCreatingHandler")
local FixedUpdateCreatingJointHandler =
  require("cradle.handlers.FixedUpdateCreatingJointHandler")
local FixedUpdateDestroyingBodyHandler =
  require("cradle.handlers.FixedUpdateDestroyingBodyHandler")
local FixedUpdateDestroyingFixtureHandler =
  require("cradle.handlers.FixedUpdateDestroyingFixtureHandler")
local FixedUpdateDestroyingHandler =
  require("cradle.handlers.FixedUpdateDestroyingHandler")
local FixedUpdateDestroyingJointHandler =
  require("cradle.handlers.FixedUpdateDestroyingJointHandler")
local FixedUpdateWorldHandler =
  require("cradle.handlers.FixedUpdateWorldHandler")
local heart = require("heart")
local nodeMod = require("cradle.node")
local KeyPressedHandler = require("cradle.handlers.KeyPressedHandler")
local sparrow = require("sparrow")
local UpdateClockHandler = require("cradle.handlers.UpdateClockHandler")

local M = Class.new()

ffi.cdef([[
  typedef struct node {
    double parent;
    double previousSibling;
    double nextSibling;
    double firstChild;
  } node;

  typedef struct tag {} tag;
]])

function M:init(application)
  self.application = assert(application)
  self.engine = heart.newEngine()
  self.engine:setProperty("application", application)

  self.engine:setProperty("clock", {
    fixedDt = 1 / 60,
    accumulatedDt = 0,
    maxAccumulatedDt = 0.1,
  })

  local database = sparrow.newDatabase()
  self.engine:setProperty("database", database)

  sparrow.newColumn(database, "body")
  sparrow.newColumn(database, "creating", "tag")
  sparrow.newColumn(database, "destroying", "tag")
  sparrow.newColumn(database, "dynamic", "tag")
  sparrow.newColumn(database, "externalBody")
  sparrow.newColumn(database, "externalFixture")
  sparrow.newColumn(database, "externalJoint")
  sparrow.newColumn(database, "fixture")
  sparrow.newColumn(database, "joint")
  sparrow.newColumn(database, "kinematic", "tag")
  sparrow.newColumn(database, "node", "node")
  sparrow.newColumn(database, "shape")
  sparrow.newColumn(database, "static", "tag")

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
    FixedUpdateWorldHandler.new(self.engine)
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
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))

  sparrow.newRow(database, {
    body = {
      position = { 0, 0.5 },
    },

    creating = {},
    fixture = {},
    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 10, 1 },
    },
  })

  local frameRow = sparrow.newRow(database, {
    body = {
      angularVelocity = 1,
      bodyType = "dynamic",
      linearVelocity = { 0, -10 },
      position = { 0, -0.6 },
    },

    creating = {},

    fixture = {
      sensor = true,
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 1.3, 0.6 },
    },
  })

  local rearWheelRow = sparrow.newRow(database, {
    body = {
      bodyType = "dynamic",
      position = { -0.65, -0.3 },
    },

    creating = {},
    fixture = {},

    joint = {
      bodyA = frameRow:getEntity(),
      jointType = "wheel",
      localAnchorA = { -0.65, 0.3 },
      springDampingRatio = 0.5,
      springFrequency = 5,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },
  })

  local frontWheelRow = sparrow.newRow(database, {
    body = {
      bodyType = "dynamic",
      position = { 0.65, -0.3 },
    },

    creating = {},
    fixture = {},

    joint = {
      bodyA = frameRow:getEntity(),
      jointType = "wheel",
      localAnchorA = { 0.65, 0.3 },
      springDampingRatio = 0.5,
      springFrequency = 5,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },
  })

  nodeMod.setParent(database, rearWheelRow:getEntity(), frameRow:getEntity())
  nodeMod.setParent(database, frontWheelRow:getEntity(), frameRow:getEntity())
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
