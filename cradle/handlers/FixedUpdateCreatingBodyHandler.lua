local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "body", "globalTransform" },
    exclusions = { "bodyObject" },
    inclusions = { "body", "creating", "globalTransform" },
    results = { "bodyObject" },
  })

  return function(dt)
    query:forEach(function(entity, body, globalTransform)
      local bodyType = body.bodyType or "static"

      local x = globalTransform.position.x
      local y = globalTransform.position.y

      local bodyObject = love.physics.newBody(world, x, y, bodyType)
      bodyObject:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle =
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      bodyObject:setAngle(angle)

      if body.angularVelocity then
        bodyObject:setAngularVelocity(body.angularVelocity)
      end

      if body.linearVelocity then
        bodyObject:setLinearVelocity(unpack(body.linearVelocity))
      end

      return bodyObject
    end)
  end
end

return M
