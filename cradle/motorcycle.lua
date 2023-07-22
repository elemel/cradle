local nodeMod = require("cradle.node")

local M = {}

function M.createMotorcycle(database, localTransform)
  local frameEntity = database:insertRow({
    bodyConfig = {
      bodyType = "dynamic",
    },

    creating = {},

    fixtureConfig = {
      friction = 0.5,
      groupIndex = -1,
    },

    localTransform = localTransform or {
      orientation = { 1, 0 },
      position = { 0, 0 },
    },

    motorcycle = {},
    node = {},

    shapeConfig = {
      shapeType = "rectangle",
      size = { 1.3, 0.3 },
    },

    transform = {},
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

    jointConfig = {
      bodyA = frameEntity,
      damping = 20,
      jointType = "wheel",
      localAnchorA = { -0.65, 0.15 },
      maxMotorTorque = 10,
      stiffness = 200,
    },

    localTransform = {
      orientation = { 1, 0 },
      position = { -0.65, 0.15 },
    },

    node = {},

    shapeConfig = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {},
    wheel = {},
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

    jointConfig = {
      bodyA = frameEntity,
      damping = 20,
      jointType = "wheel",
      localAnchorA = { 0.65, 0.15 },
      maxMotorTorque = 10,
      stiffness = 200,
    },

    localTransform = {
      orientation = { 1, 0 },
      position = { 0.65, 0.15 },
    },

    node = {},

    shapeConfig = {
      shapeType = "circle",
      radius = 0.3,
    },

    transform = {},
    wheel = {},
  })

  nodeMod.setParent(database, rearWheelEntity, frameEntity)
  nodeMod.setParent(database, frontWheelEntity, frameEntity)

  return frameEntity
end

return M
