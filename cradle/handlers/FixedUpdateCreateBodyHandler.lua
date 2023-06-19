local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "bodyConfig" },
    exclusions = { "externalBody" },
    arguments = { "entity", "bodyConfig" },
    results = { "externalBody" },
  })

  return function(dt)
    query:forEach(function(entity, bodyConfig)
      local bodyType = bodyConfig.bodyType or "static"
      local x, y = unpack(bodyConfig.position or { 0, 0 })
      local externalBody = love.physics.newBody(world, x, y, bodyType)
      externalBody:setUserData(entity)
      database:setCell(entity, bodyType, {})

      if bodyConfig.angle then
        externalBody:setAngle(bodyConfig.angle)
      end

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
