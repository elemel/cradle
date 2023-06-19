local Class = require("cradle.Class")
local DrawWorldHandler = require("cradle.handlers.DrawWorldHandler")
local ffi = require("ffi")
local FixedUpdateCreateBodyHandler =
  require("cradle.handlers.FixedUpdateCreateBodyHandler")
local FixedUpdateCreateFixtureHandler =
  require("cradle.handlers.FixedUpdateCreateFixtureHandler")
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
  sparrow.newColumn(database, "dynamic", "tag")
  sparrow.newColumn(database, "externalBody")
  sparrow.newColumn(database, "externalFixture")
  sparrow.newColumn(database, "fixture")
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
    FixedUpdateCreateBodyHandler.new(self.engine)
  )
  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateCreateFixtureHandler.new(self.engine)
  )
  self.engine:addEventHandler(
    "fixedupdate",
    FixedUpdateWorldHandler.new(self.engine)
  )

  self.engine:addEventHandler("keypressed", KeyPressedHandler.new(self.engine))
  self.engine:addEventHandler("update", UpdateClockHandler.new(self.engine))

  sparrow.newRow(database, {
    body = {
      position = { 0, 0.5 },
    },

    fixture = {
      shape = {
        shapeType = "rectangle",
        size = { 10, 1 },
      },
    },
  })

  local frameRow = sparrow.newRow(database, {
    body = {
      position = { 0, -0.6 },
    },

    fixture = {
      sensor = true,

      shape = {
        shapeType = "rectangle",
        size = { 1.3, 0.6 },
      },
    },
  })

  local rearWheelRow = sparrow.newRow(database, {
    body = {
      bodyType = "dynamic",
      position = { -0.65, -0.3 },
    },

    fixture = {
      shape = {
        shapeType = "circle",
        radius = 0.3,
      },
    },
  })

  local frontWheelRow = sparrow.newRow(database, {
    body = {
      bodyType = "dynamic",
      position = { 0.65, -0.3 },
    },

    fixture = {
      shape = {
        shapeType = "circle",
        radius = 0.3,
      },
    },
  })

  nodeMod.setParent(database, rearWheelRow:getEntity(), frameRow:getEntity())
  nodeMod.setParent(database, frontWheelRow:getEntity(), frameRow:getEntity())
end

function M:handleEvent(event, ...)
  return self.engine:handleEvent(event, ...)
end

return M
