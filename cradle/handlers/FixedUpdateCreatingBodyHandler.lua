local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "body", "creating" },
    exclusions = { "externalBody" },
    arguments = { "entity", "body" },
    results = { "externalBody" },
  })

  return function(dt)
    query:forEach(function(entity, body)
      local bodyType = body.bodyType or "static"
      local x, y = unpack(body.position or { 0, 0 })
      local externalBody = love.physics.newBody(world, x, y, bodyType)
      externalBody:setUserData(entity)
      database:setCell(entity, bodyType, {})

      if body.angle then
        externalBody:setAngle(body.angle)
      end

      if body.angularVelocity then
        externalBody:setAngularVelocity(body.angularVelocity)
      end

      if body.linearVelocity then
        externalBody:setLinearVelocity(unpack(body.linearVelocity))
      end

      return externalBody
    end)
  end
end

return M
