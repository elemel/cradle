local nodeMod = require("cradle.node")

local M = {}

local function createNeckAndHead(database, trunkEntity, localCollarPosition)
  local localCollarX, localCollarY = unpack(localCollarPosition)

  local localNeckX = localCollarX
  local localNeckY = localCollarY - 0.05

  local neckEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      limitsEnabled = true,
      localAnchorA = localCollarPosition,
      localAnchorB = { 0, 0.05 },
      lowerLimit = -0.125 * math.pi,
      type = "revolute",
      upperLimit = 0.125 * math.pi,
    },

    node = {},

    shape = {
      size = { 0.1, 0.1 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { localNeckX, localNeckY },
    },
  })

  local headEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = neckEntity,
      limitsEnabled = true,
      localAnchorA = { 0, -0.05 },
      localAnchorB = { 0, 0.1 },
      lowerLimit = -0.125 * math.pi,
      type = "revolute",
      upperLimit = 0.125 * math.pi,
    },

    node = {},

    shape = {
      size = { 0.2, 0.2 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { 0, -0.15 },
    },
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
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      localAnchorA = localShoulderPosition,
      localAnchorB = { 0, -0.175 },
      type = "revolute",
    },

    node = {},

    shape = {
      size = { 0.1, 0.35 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { localUpperArmX, localUpperArmY },
    },
  })

  local lowerArmEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = upperArmEntity,
      limitsEnabled = true,
      localAnchorA = { 0, 0.175 },
      localAnchorB = { 0, -0.175 },
      lowerLimit = -math.pi,
      type = "revolute",
      upperLimit = 0,
    },

    node = {},

    shape = {
      size = { 0.1, 0.35 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { 0, 0.35 },
    },
  })

  local handEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = lowerArmEntity,
      limitsEnabled = true,
      localAnchorA = { 0, 0.175 },
      localAnchorB = { 0, -0.05 },
      lowerLimit = -0.25 * math.pi,
      type = "revolute",
      upperLimit = 0.25 * math.pi,
    },

    node = {},

    shape = {
      size = { 0.1, 0.1 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { 0, 0.225 },
    },
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
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = trunkEntity,
      localAnchorA = localHipPosition,
      localAnchorB = { 0, -0.225 },
      type = "revolute",
    },

    node = {},

    shape = {
      size = { 0.15, 0.45 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { localUpperLegX, localUpperLegY },
    },
  })

  local lowerLegEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = upperLegEntity,
      limitsEnabled = true,
      localAnchorA = { 0, 0.225 },
      localAnchorB = { 0, -0.225 },
      lowerLimit = 0,
      type = "revolute",
      upperLimit = math.pi,
    },

    node = {},

    shape = {
      size = { 0.1, 0.45 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { 0, 0.35 },
    },
  })

  local footEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    joint = {
      bodyA = lowerLegEntity,
      limitsEnabled = true,
      localAnchorA = { 0, 0.225 },
      localAnchorB = { -0.075, -0.05 },
      lowerLimit = -0.25 * math.pi,
      type = "revolute",
      upperLimit = 0.25 * math.pi,
    },

    node = {},

    shape = {
      size = { 0.25, 0.05 },
      type = "rectangle",
    },

    transform = {
      orientation = { 1, 0 },
      position = { 0.075, 0.25 },
    },
  })

  local localFootBarX = localHipX - 0.3
  local localFootBarY = 0.15

  local footPegEntity = database:insertRow({
    creating = {},

    joint = {
      bodyA = frameEntity,
      bodyB = footEntity,
      limitsEnabled = true,
      localAnchorA = { localFootBarX, localFootBarY },
      localAnchorB = { 0, 0.025 },
      lowerLimit = -0.25 * math.pi,
      type = "revolute",
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

function M.createRider(database, frameEntity, transform)
  local trunkEntity = database:insertRow({
    bodyConfig = {
      type = "dynamic",
    },

    creating = {},

    fixture = {
      friction = 0.5,
      groupIndex = -1,
    },

    node = {},
    rider = {},

    shape = {
      size = { 0.3, 0.7 },
      type = "rectangle",
    },

    joint = {
      angularOffset = 0.125 * math.pi,
      bodyA = frameEntity,
      linearOffset = { 0, -0.75 },
      maxForce = 100,
      maxTorque = 10,
      type = "motor",
    },

    transform = transform or {
      orientation = { 1, 0 },
      position = { 0, 0 },
    },
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
