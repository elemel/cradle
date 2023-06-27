local nodeMod = require("cradle.node")

local M = {}

function M.createMotorcycle(database, localTransform)
  local frameEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    localTransform = localTransform or {
      rotation = { 1, 0 },
      translation = { 0, 0 },
    },

    motorcycle = {},
    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 1.3, 0.3 },
    },

    transform = {},
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
      localAnchorA = { -0.65, 0.15 },
      maxMotorTorque = 10,
      springDampingRatio = 1,
      springFrequency = 10,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { -0.65, 0.15 },
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {},
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
      localAnchorA = { 0.65, 0.15 },
      maxMotorTorque = 10,
      springDampingRatio = 1,
      springFrequency = 10,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0.65, 0.15 },
    },

    node = {},

    shape = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {},
  })

  nodeMod.setParent(database, rearWheelEntity, frameEntity)
  nodeMod.setParent(database, frontWheelEntity, frameEntity)

  return frameEntity
end

return M
