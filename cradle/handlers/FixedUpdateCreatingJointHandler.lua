local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "joint" },
    exclusions = { "jointObject" },
    arguments = { "joint" },
    results = { "jointObject" },
  })

  return function(dt)
    query:forEach(function(entity, joint)
      local jointType = assert(joint.type)

      if jointType == "motor" then
        return M.createMotorJoint(database, world, entity, joint)
      elseif jointType == "revolute" then
        return M.createRevoluteJoint(database, world, entity, joint)
      elseif jointType == "wheel" then
        return M.createWheelJoint(database, world, entity, joint)
      else
        error("Invalid joint type: " .. jointType)
      end
    end)
  end
end

function M.createMotorJoint(database, world, entity, joint)
  local bodyEntityA = joint.bodyA or entity
  local bodyEntityB = joint.bodyB or entity

  local bodyObjectA = assert(database:getCell(bodyEntityA, "bodyObject"))
  local bodyObjectB = assert(database:getCell(bodyEntityB, "bodyObject"))

  local correctionFactor = joint.correctionFactor or 0.3
  local collideConnected = false

  if joint.collideConnected ~= nil then
    collideConnected = joint.collideConnected
  end

  local jointObject = love.physics.newMotorJoint(
    bodyObjectA,
    bodyObjectB,
    correctionFactor,
    collideConnected
  )

  if joint.linearOffset then
    jointObject:setLinearOffset(unpack(joint.linearOffset))
  end

  if joint.angularOffset then
    jointObject:setAngularOffset(joint.angularOffset)
  end

  if joint.maxForce then
    jointObject:setMaxForce(joint.maxForce)
  end

  if joint.maxTorque then
    jointObject:setMaxTorque(joint.maxTorque)
  end

  jointObject:setUserData(entity)
  return jointObject
end

function M.createRevoluteJoint(database, world, entity, joint)
  local bodyEntityA = joint.bodyA or entity
  local bodyEntityB = joint.bodyB or entity

  local bodyObjectA = assert(database:getCell(bodyEntityA, "bodyObject"))
  local bodyObjectB = assert(database:getCell(bodyEntityB, "bodyObject"))

  local ax, ay =
    bodyObjectA:getWorldPoint(unpack(joint.localAnchorA or { 0, 0 }))
  local bx, by =
    bodyObjectB:getWorldPoint(unpack(joint.localAnchorB or { 0, 0 }))

  local collideConnected = false

  if joint.collideConnected ~= nil then
    collideConnected = joint.collideConnected
  end

  local referenceAngle = joint.referenceAngle or 0

  local jointObject = love.physics.newRevoluteJoint(
    bodyObjectA,
    bodyObjectB,
    ax,
    ay,
    bx,
    by,
    collideConnected,
    referenceAngle
  )

  if joint.limitsEnabled ~= nil then
    jointObject:setLimitsEnabled(joint.limitsEnabled)
  end

  if joint.lowerLimit then
    jointObject:setLowerLimit(joint.lowerLimit)
  end

  if joint.upperLimit then
    jointObject:setUpperLimit(joint.upperLimit)
  end

  jointObject:setUserData(entity)
  return jointObject
end

function M.createWheelJoint(database, world, entity, joint)
  local bodyEntityA = joint.bodyA or entity
  local bodyEntityB = joint.bodyB or entity

  local bodyObjectA = assert(database:getCell(bodyEntityA, "bodyObject"))
  local bodyObjectB = assert(database:getCell(bodyEntityB, "bodyObject"))

  local ax, ay =
    bodyObjectA:getWorldPoint(unpack(joint.localAnchorA or { 0, 0 }))
  local bx, by =
    bodyObjectB:getWorldPoint(unpack(joint.localAnchorB or { 0, 0 }))
  local axisX, axisY =
    bodyObjectA:getWorldVector(unpack(joint.localAxisA or { 0, -1 }))

  local collideConnected = false

  if joint.collideConnected ~= nil then
    collideConnected = joint.collideConnected
  end

  local jointObject = love.physics.newWheelJoint(
    bodyObjectA,
    bodyObjectB,
    ax,
    ay,
    bx,
    by,
    axisX,
    axisY,
    collideConnected
  )

  jointObject:setUserData(entity)

  if joint.maxMotorTorque then
    jointObject:setMaxMotorTorque(joint.maxMotorTorque)
  end

  if joint.damping then
    jointObject:setDamping(joint.damping)
  end

  if joint.stiffness then
    jointObject:setStiffness(joint.stiffness)
  end

  return jointObject
end

return M
