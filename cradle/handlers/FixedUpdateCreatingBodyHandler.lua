local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "bodyConfig", "globalTransform" },
    exclusions = { "bodyObject" },
    inclusions = { "bodyConfig", "creating", "globalTransform" },
    results = { "bodyObject" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig, globalTransform)
      local bodyType = bodyConfig.bodyType or "static"

      local x = globalTransform.position.x
      local y = globalTransform.position.y

      local bodyObject = love.physics.newBody(world, x, y, bodyType)
      bodyObject:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle =
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      bodyObject:setAngle(angle)

      if bodyConfig.angularVelocity then
        bodyObject:setAngularVelocity(bodyConfig.angularVelocity)
      end

      if bodyConfig.linearVelocity then
        bodyObject:setLinearVelocity(unpack(bodyConfig.linearVelocity))
      end

      return bodyObject
    end)
  end
end

return M
