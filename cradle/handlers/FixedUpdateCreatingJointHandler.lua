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
      else
        error("Invalid joint type: " .. jointType)
      end
    end)
  end
end

function M.createRevoluteJoint(database, world, entity, joint)
  local a = joint.a or entity
  local b = joint.b or entity

  local externalBodyA = assert(database:getCell(a, "externalBody"))
  local externalBodyB = assert(database:getCell(b, "externalBody"))

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
  externalJoint:setUserData(entity)
  return externalJoint
end

return M
