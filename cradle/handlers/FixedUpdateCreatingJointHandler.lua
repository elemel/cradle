local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "jointConfig" },
    exclusions = { "externalJoint" },
    arguments = { "entity", "jointConfig" },
    results = { "externalJoint" },
  })

  return function(dt)
    query:forEach(function(entity, jointConfig)
      local jointType = assert(jointConfig.jointType)

      if jointType == "motor" then
        return M.createMotorJoint(database, world, entity, jointConfig)
      elseif jointType == "revolute" then
        return M.createRevoluteJoint(database, world, entity, jointConfig)
      elseif jointType == "wheel" then
        return M.createWheelJoint(database, world, entity, jointConfig)
      else
        error("Invalid joint type: " .. jointType)
      end
    end)
  end
end

function M.createMotorJoint(database, world, entity, jointConfig)
  local bodyEntityA = jointConfig.bodyA or entity
  local bodyEntityB = jointConfig.bodyB or entity

  local externalBodyA = assert(database:getCell(bodyEntityA, "externalBody"))
  local externalBodyB = assert(database:getCell(bodyEntityB, "externalBody"))

  local correctionFactor = jointConfig.correctionFactor or 0.3
  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local externalJoint = love.physics.newMotorJoint(
    externalBodyA,
    externalBodyB,
    correctionFactor,
    collideConnected
  )

  if jointConfig.linearOffset then
    externalJoint:setLinearOffset(unpack(jointConfig.linearOffset))
  end

  if jointConfig.angularOffset then
    externalJoint:setAngularOffset(jointConfig.angularOffset)
  end

  if jointConfig.maxForce then
    externalJoint:setMaxForce(jointConfig.maxForce)
  end

  if jointConfig.maxTorque then
    externalJoint:setMaxTorque(jointConfig.maxTorque)
  end

  externalJoint:setUserData(entity)
  return externalJoint
end

function M.createRevoluteJoint(database, world, entity, jointConfig)
  local bodyEntityA = jointConfig.bodyA or entity
  local bodyEntityB = jointConfig.bodyB or entity

  local externalBodyA = assert(database:getCell(bodyEntityA, "externalBody"))
  local externalBodyB = assert(database:getCell(bodyEntityB, "externalBody"))

  local ax, ay =
    externalBodyA:getWorldPoint(unpack(jointConfig.localAnchorA or { 0, 0 }))
  local bx, by =
    externalBodyB:getWorldPoint(unpack(jointConfig.localAnchorB or { 0, 0 }))

  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local referenceAngle = jointConfig.referenceAngle or 0

  local externalJoint = love.physics.newRevoluteJoint(
    externalBodyA,
    externalBodyB,
    ax,
    ay,
    bx,
    by,
    collideConnected,
    referenceAngle
  )

  if jointConfig.limitsEnabled ~= nil then
    externalJoint:setLimitsEnabled(jointConfig.limitsEnabled)
  end

  if jointConfig.lowerLimit then
    externalJoint:setLowerLimit(jointConfig.lowerLimit)
  end

  if jointConfig.upperLimit then
    externalJoint:setUpperLimit(jointConfig.upperLimit)
  end

  externalJoint:setUserData(entity)
  return externalJoint
end

function M.createWheelJoint(database, world, entity, jointConfig)
  local bodyEntityA = jointConfig.bodyA or entity
  local bodyEntityB = jointConfig.bodyB or entity

  local externalBodyA = assert(database:getCell(bodyEntityA, "externalBody"))
  local externalBodyB = assert(database:getCell(bodyEntityB, "externalBody"))

  local ax, ay =
    externalBodyA:getWorldPoint(unpack(jointConfig.localAnchorA or { 0, 0 }))
  local bx, by =
    externalBodyB:getWorldPoint(unpack(jointConfig.localAnchorB or { 0, 0 }))
  local axisX, axisY =
    externalBodyA:getWorldVector(unpack(jointConfig.localAxisA or { 0, -1 }))

  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local externalJoint = love.physics.newWheelJoint(
    externalBodyA,
    externalBodyB,
    ax,
    ay,
    bx,
    by,
    axisX,
    axisY,
    collideConnected
  )

  externalJoint:setUserData(entity)

  if jointConfig.maxMotorTorque then
    externalJoint:setMaxMotorTorque(jointConfig.maxMotorTorque)
  end

  if jointConfig.damping then
    externalJoint:setDamping(jointConfig.damping)
  end

  if jointConfig.stiffness then
    externalJoint:setStiffness(jointConfig.stiffness)
  end

  return externalJoint
end

return M
