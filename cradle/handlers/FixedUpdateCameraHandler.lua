local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local cameraQuery = sparrow.newQuery(database, {
    arguments = { "transform" },
    inclusions = { "camera", "transform" },
  })

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "body" },
    inclusions = { "body", "rider" },
  })

  return function(dt)
    cameraQuery:forEach(function(cameraEntity, transform)
      riderQuery:forEach(function(riderEntity, body)
        transform.position.x, transform.position.y = body:getPosition()
      end)
    end)
  end
end

return M
