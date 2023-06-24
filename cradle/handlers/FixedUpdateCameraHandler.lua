local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local cameraQuery = sparrow.newQuery(database, {
    arguments = { "transform" },
    inclusions = { "camera", "transform" },
  })

  local frameQuery = sparrow.newQuery(database, {
    arguments = { "externalBody" },
    inclusions = { "externalBody", "frame" },
  })

  return function(dt)
    cameraQuery:forEach(function(transform)
      frameQuery:forEach(function(externalBody)
        transform.translation.x, transform.translation.y =
          externalBody:getPosition()
      end)
    end)
  end
end

return M
