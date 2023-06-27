local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "joint", "creating" },
    exclusions = { "externalJoint" },
    arguments = { "entity", "joint" },
    results = { "externalJoint" },
  })

  return function(dt)
    query:forEach(function(entity, joint)
      local jointType = assert(joint.jointType)

      if jointType == "revolute" then
        return M.createRevoluteJoint(database, world, entity, joint)
      elseif jointType == "wheel" then
        return M.createWheelJoint(database, world, entity, joint)
      else
        error("Invalid joint type: " .. jointType)
      end
    end)
  end
end

function M.createRevoluteJoint(database, world, entity, joint)
  local bodyEntityA = joint.bodyA or entity
  local bodyEntityB = joint.bodyB or entity

  local externalBodyA = assert(database:getCell(bodyEntityA, "externalBody"))
  local externalBodyB = assert(database:getCell(bodyEntityB, "externalBody"))

  local ax, ay =
    externalBodyA:getWorldPoint(unpack(joint.localAnchorA or { 0, 0 }))
  local bx, by =
    externalBodyB:getWorldPoint(unpack(joint.localAnchorB or { 0, 0 }))

  local collideConnected = false

  if joint.collideConnected ~= nil then
    collideConnected = joint.collideConnected
  end

  local referenceAngle = joint.referenceAngle or 0

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

  if joint.limitsEnabled ~= nil then
    externalJoint:setLimitsEnabled(joint.limitsEnabled)
  end

  if joint.lowerLimit then
    externalJoint:setLowerLimit(joint.lowerLimit)
  end

  if joint.upperLimit then
    externalJoint:setUpperLimit(joint.upperLimit)
  end

  externalJoint:setUserData(entity)
  return externalJoint
end

function M.createWheelJoint(database, world, entity, joint)
  local bodyEntityA = joint.bodyA or entity
  local bodyEntityB = joint.bodyB or entity

  local externalBodyA = assert(database:getCell(bodyEntityA, "externalBody"))
  local externalBodyB = assert(database:getCell(bodyEntityB, "externalBody"))

  local ax, ay =
    externalBodyA:getWorldPoint(unpack(joint.localAnchorA or { 0, 0 }))
  local bx, by =
    externalBodyB:getWorldPoint(unpack(joint.localAnchorB or { 0, 0 }))
  local axisX, axisY =
    externalBodyA:getWorldVector(unpack(joint.localAxisA or { 0, -1 }))

  local collideConnected = false

  if joint.collideConnected ~= nil then
    collideConnected = joint.collideConnected
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

  if joint.maxMotorTorque then
    externalJoint:setMaxMotorTorque(joint.maxMotorTorque)
  end

  if joint.springDampingRatio then
    externalJoint:setSpringDampingRatio(joint.springDampingRatio)
  end

  if joint.springFrequency then
    externalJoint:setSpringFrequency(joint.springFrequency)
  end

  return externalJoint
end

return M
