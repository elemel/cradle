local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "jointConfig" },
    exclusions = { "jointObject" },
    arguments = { "jointConfig" },
    results = { "jointObject" },
  })

  return function(dt)
    query:forEach(function(entity, jointConfig)
      local jointType = assert(jointConfig.type)

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

  local jointObject =
    love.physics.newMotorJoint(bodyA, bodyB, correctionFactor, collideConnected)

  if jointConfig.linearOffset then
    jointObject:setLinearOffset(unpack(jointConfig.linearOffset))
  end

  if jointConfig.angularOffset then
    jointObject:setAngularOffset(jointConfig.angularOffset)
  end

  if jointConfig.maxForce then
    jointObject:setMaxForce(jointConfig.maxForce)
  end

  if jointConfig.maxTorque then
    jointObject:setMaxTorque(jointConfig.maxTorque)
  end

  jointObject:setUserData(entity)
  return jointObject
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

  local jointObject = love.physics.newRevoluteJoint(
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
    jointObject:setLimitsEnabled(jointConfig.limitsEnabled)
  end

  if jointConfig.lowerLimit then
    jointObject:setLowerLimit(jointConfig.lowerLimit)
  end

  if jointConfig.upperLimit then
    jointObject:setUpperLimit(jointConfig.upperLimit)
  end

  jointObject:setUserData(entity)
  return jointObject
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

  local jointObject = love.physics.newWheelJoint(
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

  jointObject:setUserData(entity)

  if jointConfig.maxMotorTorque then
    jointObject:setMaxMotorTorque(jointConfig.maxMotorTorque)
  end

  if jointConfig.damping then
    jointObject:setDamping(jointConfig.damping)
  end

  if jointConfig.stiffness then
    jointObject:setStiffness(jointConfig.stiffness)
  end

  return jointObject
end

return M
