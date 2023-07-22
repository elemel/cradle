local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "jointConfig" },
    exclusions = { "joint" },
    arguments = { "jointConfig" },
    results = { "joint" },
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

  local bodyA = assert(database:getCell(bodyEntityA, "body"))
  local bodyB = assert(database:getCell(bodyEntityB, "body"))

  local correctionFactor = jointConfig.correctionFactor or 0.3
  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local joint =
    love.physics.newMotorJoint(bodyA, bodyB, correctionFactor, collideConnected)

  if jointConfig.linearOffset then
    joint:setLinearOffset(unpack(jointConfig.linearOffset))
  end

  if jointConfig.angularOffset then
    joint:setAngularOffset(jointConfig.angularOffset)
  end

  if jointConfig.maxForce then
    joint:setMaxForce(jointConfig.maxForce)
  end

  if jointConfig.maxTorque then
    joint:setMaxTorque(jointConfig.maxTorque)
  end

  joint:setUserData(entity)
  return joint
end

function M.createRevoluteJoint(database, world, entity, jointConfig)
  local bodyEntityA = jointConfig.bodyA or entity
  local bodyEntityB = jointConfig.bodyB or entity

  local bodyA = assert(database:getCell(bodyEntityA, "body"))
  local bodyB = assert(database:getCell(bodyEntityB, "body"))

  local ax, ay =
    bodyA:getWorldPoint(unpack(jointConfig.localAnchorA or { 0, 0 }))
  local bx, by =
    bodyB:getWorldPoint(unpack(jointConfig.localAnchorB or { 0, 0 }))

  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local referenceAngle = jointConfig.referenceAngle or 0

  local joint = love.physics.newRevoluteJoint(
    bodyA,
    bodyB,
    ax,
    ay,
    bx,
    by,
    collideConnected,
    referenceAngle
  )

  if jointConfig.limitsEnabled ~= nil then
    joint:setLimitsEnabled(jointConfig.limitsEnabled)
  end

  if jointConfig.lowerLimit then
    joint:setLowerLimit(jointConfig.lowerLimit)
  end

  if jointConfig.upperLimit then
    joint:setUpperLimit(jointConfig.upperLimit)
  end

  joint:setUserData(entity)
  return joint
end

function M.createWheelJoint(database, world, entity, jointConfig)
  local bodyEntityA = jointConfig.bodyA or entity
  local bodyEntityB = jointConfig.bodyB or entity

  local bodyA = assert(database:getCell(bodyEntityA, "body"))
  local bodyB = assert(database:getCell(bodyEntityB, "body"))

  local ax, ay =
    bodyA:getWorldPoint(unpack(jointConfig.localAnchorA or { 0, 0 }))
  local bx, by =
    bodyB:getWorldPoint(unpack(jointConfig.localAnchorB or { 0, 0 }))
  local axisX, axisY =
    bodyA:getWorldVector(unpack(jointConfig.localAxisA or { 0, -1 }))

  local collideConnected = false

  if jointConfig.collideConnected ~= nil then
    collideConnected = jointConfig.collideConnected
  end

  local joint = love.physics.newWheelJoint(
    bodyA,
    bodyB,
    ax,
    ay,
    bx,
    by,
    axisX,
    axisY,
    collideConnected
  )

  joint:setUserData(entity)

  if jointConfig.maxMotorTorque then
    joint:setMaxMotorTorque(jointConfig.maxMotorTorque)
  end

  if jointConfig.damping then
    joint:setDamping(jointConfig.damping)
  end

  if jointConfig.stiffness then
    joint:setStiffness(jointConfig.stiffness)
  end

  return joint
end

return M
