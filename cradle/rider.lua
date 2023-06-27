local nodeMod = require("cradle.node")

local M = {}

local function createNeckAndHead(database, trunkEntity, localCollarPosition)
  local localCollarX, localCollarY = unpack(localCollarPosition)

  local localNeckX = localCollarX
  local localNeckY = localCollarY - 0.05

  local neckEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = localCollarPosition,
      localAnchorB = { 0, 0.05 },
      lowerLimit = -0.125 * math.pi,
      upperLimit = 0.125 * math.pi,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { localNeckX, localNeckY },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.1, 0.1 },
    },

    transform = {},
  })

  local headEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = neckEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { 0, -0.05 },
      localAnchorB = { 0, 0.1 },
      lowerLimit = -0.125 * math.pi,
      upperLimit = 0.125 * math.pi,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0, -0.15 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.2, 0.2 },
    },

    transform = {},
  })

  nodeMod.setParent(database, neckEntity, trunkEntity)
  nodeMod.setParent(database, headEntity, neckEntity)

  return neckEntity
end

local function createArm(database, trunkEntity, localShoulderPosition)
  local localShoulderX, localShoulderY = unpack(localShoulderPosition)

  local localUpperArmX = localShoulderX
  local localUpperArmY = localShoulderY + 0.175

  local upperArmEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      jointType = "revolute",
      localAnchorA = localShoulderPosition,
      localAnchorB = { 0, -0.175 },
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { localUpperArmX, localUpperArmY },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.1, 0.35 },
    },

    transform = {},
  })

  local lowerArmEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = upperArmEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { 0, 0.175 },
      localAnchorB = { 0, -0.175 },
      lowerLimit = -math.pi,
      upperLimit = 0,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0, 0.35 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.1, 0.35 },
    },

    transform = {},
  })

  local handEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = lowerArmEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { 0, 0.175 },
      localAnchorB = { 0, -0.05 },
      lowerLimit = -0.25 * math.pi,
      upperLimit = 0.25 * math.pi,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0, 0.225 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.1, 0.1 },
    },

    transform = {},
  })

  nodeMod.setParent(database, upperArmEntity, trunkEntity)
  nodeMod.setParent(database, lowerArmEntity, upperArmEntity)
  nodeMod.setParent(database, handEntity, lowerArmEntity)

  return upperArmEntity
end

local function createLeg(database, frameEntity, trunkEntity, localHipPosition)
  local localHipX, localHipY = unpack(localHipPosition)

  local localUpperLegX = localHipX
  local localUpperLegY = localHipY + 0.225

  local upperLegEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      jointType = "revolute",
      localAnchorA = localHipPosition,
      localAnchorB = { 0, -0.225 },
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { localUpperLegX, localUpperLegY },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.15, 0.45 },
    },

    transform = {},
  })

  local lowerLegEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = upperLegEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { 0, 0.225 },
      localAnchorB = { 0, -0.225 },
      lowerLimit = 0,
      upperLimit = math.pi,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0, 0.35 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.1, 0.45 },
    },

    transform = {},
  })

  local footEntity = database:insertRow({
    body = {
      bodyType = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = lowerLegEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { 0, 0.225 },
      localAnchorB = { -0.075, -0.05 },
      lowerLimit = -0.25 * math.pi,
      upperLimit = 0.25 * math.pi,
    },

    localTransform = {
      rotation = { 1, 0 },
      translation = { 0.075, 0.25 },
    },

    node = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.25, 0.05 },
    },

    transform = {},
  })

  local localFootBarX = localHipX - 0.3
  local localFootBarY = 0.15

  local footPegEntity = database:insertRow({
    creating = {},

    joint = {
      bodyA = frameEntity,
      bodyB = footEntity,
      jointType = "revolute",
      limitsEnabled = true,
      localAnchorA = { localFootBarX, localFootBarY },
      localAnchorB = { 0, 0.025 },
      lowerLimit = -0.25 * math.pi,
      upperLimit = 0.25 * math.pi,
    },

    node = {},
  })

  nodeMod.setParent(database, upperLegEntity, trunkEntity)
  nodeMod.setParent(database, lowerLegEntity, upperLegEntity)
  nodeMod.setParent(database, footEntity, lowerLegEntity)
  nodeMod.setParent(database, footPegEntity, frameEntity)

  return upperLegEntity
end

function M.createRider(database, frameEntity, localTransform)
  local trunkEntity = database:insertRow({
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

    node = {},
    rider = {},

    shape = {
      shapeType = "rectangle",
      size = { 0.3, 0.7 },
    },

    transform = {},
  })

  nodeMod.setParent(database, trunkEntity, frameEntity)

  createNeckAndHead(database, trunkEntity, { 0, -0.35 })

  createArm(database, trunkEntity, { -0.1, -0.3 })
  createArm(database, trunkEntity, { 0.1, -0.3 })

  createLeg(database, frameEntity, trunkEntity, { -0.075, 0.275 })
  createLeg(database, frameEntity, trunkEntity, { 0.075, 0.275 })

  return trunkEntity
end

return M
