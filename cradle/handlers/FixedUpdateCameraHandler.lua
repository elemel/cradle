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
    cameraQuery:forEach(function(transform)
      riderQuery:forEach(function(body)
        transform.translation.x, transform.translation.y = body:getPosition()
      end)
    end)
  end
end

return M
