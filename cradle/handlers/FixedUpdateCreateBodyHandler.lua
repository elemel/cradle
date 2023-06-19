local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "bodyConfig" },
    exclusions = { "body" },
    arguments = { "entity", "bodyConfig" },
    results = { "body" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig)
      local bodyType = bodyConfig.bodyType or "static"
      local x, y = unpack(bodyConfig.position or { 0, 0 })
      local body = love.physics.newBody(world, x, y, bodyType)
      body:setUserData(entity)
      database:setCell(entity, bodyType, {})

      if bodyConfig.angle then
        body:setAngle(bodyConfig.angle)
      end

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
