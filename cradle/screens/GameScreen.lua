local Class = require("cradle.Class")
local DrawWorldHandler = require("cradle.handlers.DrawWorldHandler")
local ffi = require("ffi")
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

  typedef struct vec2 {
    double x;
    double y;
  } vec2;

  typedef struct transform {
    vec2 translation;
    complex rotation;
  } transform;
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

  database:createColumn("body")
  database:createColumn("camera", "tag")
  database:createColumn("creating", "tag")
  database:createColumn("destroying", "tag")
  database:createColumn("dynamic", "tag")
  database:createColumn("externalBody")
  database:createColumn("externalFixture")
  database:createColumn("externalJoint")
  database:createColumn("fixture")
  database:createColumn("frame", "tag")
  database:createColumn("joint")
  database:createColumn("kinematic", "tag")
  database:createColumn("node", "node")
  database:createColumn("position", "vec2")
  database:createColumn("shape")
  database:createColumn("static", "tag")
  database:createColumn("transform", "transform")
  database:createColumn("worldTransform", "transform")

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
    FixedUpdateInputHandler.new(self.engine)
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
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {
      rotation = { 1, 0 },
      translation = { 0, 0.5 },
    },
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {
      rotation = { math.cos(-0.5), math.sin(-0.5) },
      translation = { 4, -0.5 },
    },
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {
      rotation = { math.cos(0.5), math.sin(0.5) },
      translation = { 15, -0.5 },
    },
  })

  database:insertRow({
    body = {},
    creating = {},

    fixture = {
      friction = 0.5,
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 5, 1 },
    },

    transform = {
      rotation = { 1, 0 },
      translation = { 19, 0.5 },
    },
  })

  local frameEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    frame = {},
    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 1.3, 0.6 },
    },

    transform = {
      rotation = { 1, 0 },
      translation = { 0, -0.6 },
    },
  })

  local rearWheelEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 2,
      groupIndex = -1,
    },

    joint = {
      bodyA = frameEntity,
      jointType = "wheel",
      localAnchorA = { -0.65, 0.3 },
      maxMotorTorque = 10,
      springDampingRatio = 0.5,
      springFrequency = 5,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {
      rotation = { 1, 0 },
      translation = { -0.65, -0.3 },
    },
  })

  local frontWheelEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 2,
      groupIndex = -1,
    },

    joint = {
      bodyA = frameEntity,
      jointType = "wheel",
      localAnchorA = { 0.65, 0.3 },
      maxMotorTorque = 10,
      springDampingRatio = 0.5,
      springFrequency = 5,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {
      rotation = { 1, 0 },
      translation = { 0.65, -0.3 },
    },
  })

  nodeMod.setParent(database, rearWheelEntity, frameEntity)
  nodeMod.setParent(database, frontWheelEntity, frameEntity)

  database:insertRow({
    camera = {},

    transform = {
      translation = { 0, 0 },
      rotation = { 1, 0 },
    },
  })
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
