local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local cameraQuery = sparrow.newQuery(database, {
    arguments = { "position" },
    inclusions = { "camera", "position" },
  })

  local frameQuery = sparrow.newQuery(database, {
    arguments = { "externalBody" },
    inclusions = { "externalBody", "frame" },
  })

  return function(dt)
    cameraQuery:forEach(function(position)
      frameQuery:forEach(function(externalBody)
        position.x, position.y = externalBody:getPosition()
      end)
    end)
  end
end

return M
