local nodeMod = require("cradle.node")

local M = {}

function M.createMotorcycle(database, transform)
  local frameEntity = database:insertRow({
    bodyConfig = {
      bodyType = "dynamic",
    },

    creating = {},

    fixtureConfig = {
      friction = 0.5,
      groupIndex = -1,
    },

    globalTransform = {},

    motorcycle = {},
    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 1.3, 0.3 },
    },

    transform = transform or {
      orientation = { 1, 0 },
      position = { 0, 0 },
    },
  })

  local rearWheelEntity = database:insertRow({
    bodyConfig = {
      bodyType = "dynamic",
    },

    creating = {},

    fixtureConfig = {
      friction = 2,
      groupIndex = -1,
    },

    globalTransform = {},

    jointConfig = {
      bodyA = frameEntity,
      damping = 20,
      jointType = "wheel",
      localAnchorA = { -0.65, 0.15 },
      maxMotorTorque = 10,
      stiffness = 200,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    wheel = {},

    transform = {
      orientation = { 1, 0 },
      position = { -0.65, 0.15 },
    },
  })

  local frontWheelEntity = database:insertRow({
    bodyConfig = {
      bodyType = "dynamic",
    },

    creating = {},

    fixtureConfig = {
      friction = 2,
      groupIndex = -1,
    },

    globalTransform = {},

    jointConfig = {
      bodyA = frameEntity,
      damping = 20,
      jointType = "wheel",
      localAnchorA = { 0.65, 0.15 },
      maxMotorTorque = 10,
      stiffness = 200,
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    wheel = {},

    transform = {
      orientation = { 1, 0 },
      position = { 0.65, 0.15 },
    },
  })

  nodeMod.setParent(database, rearWheelEntity, frameEntity)
  nodeMod.setParent(database, frontWheelEntity, frameEntity)

  return frameEntity
end

return M
