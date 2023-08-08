local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "bodyConfig", "globalTransform" },
    exclusions = { "body" },
    inclusions = { "bodyConfig", "creating", "globalTransform" },
    results = { "body" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig, globalTransform)
      local bodyType = bodyConfig.type or "static"

      local x = globalTransform.position.x
      local y = globalTransform.position.y

      local body = love.physics.newBody(world, x, y, bodyType)
      body:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle =
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      body:setAngle(angle)

      if bodyConfig.angularVelocity then
        body:setAngularVelocity(bodyConfig.angularVelocity)
      end

      if bodyConfig.linearVelocity then
        body:setLinearVelocity(unpack(bodyConfig.linearVelocity))
      end

      return body
    end)
  end
end

return M
