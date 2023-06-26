local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    arguments = { "entity", "body", "transform" },
    exclusions = { "externalBody" },
    inclusions = { "body", "creating", "transform" },
    results = { "externalBody" },
  })

  return function(dt)
    query:forEach(function(entity, body, transform)
      local bodyType = body.bodyType or "static"

      local x = transform.translation.x
      local y = transform.translation.y

      local externalBody = love.physics.newBody(world, x, y, bodyType)
      externalBody:setUserData(entity)
      database:setCell(entity, bodyType, {})

      local angle = math.atan2(transform.rotation.y, transform.rotation.x)
      externalBody:setAngle(angle)

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
