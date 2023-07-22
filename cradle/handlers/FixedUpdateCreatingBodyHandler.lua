local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "bodyConfig", "transform" },
    exclusions = { "body" },
    inclusions = { "bodyConfig", "creating", "transform" },
    results = { "body" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig, transform)
      local bodyType = bodyConfig.bodyType or "static"

      local x = transform.translation.x
      local y = transform.translation.y

      local body = love.physics.newBody(world, x, y, bodyType)
      body:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle = math.atan2(transform.rotation.y, transform.rotation.x)
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
