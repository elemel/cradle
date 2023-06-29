local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "entity", "bodyConfig", "transform" },
    exclusions = { "externalBody" },
    inclusions = { "bodyConfig", "creating", "transform" },
    results = { "externalBody" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig, transform)
      local bodyType = bodyConfig.bodyType or "static"

      local x = transform.translation.x
      local y = transform.translation.y

      local externalBody = love.physics.newBody(world, x, y, bodyType)
      externalBody:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle = math.atan2(transform.rotation.y, transform.rotation.x)
      externalBody:setAngle(angle)

      if bodyConfig.angularVelocity then
        externalBody:setAngularVelocity(bodyConfig.angularVelocity)
      end

      if bodyConfig.linearVelocity then
        externalBody:setLinearVelocity(unpack(bodyConfig.linearVelocity))
      end

      return externalBody
    end)
  end
end

return M
