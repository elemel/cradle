local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local cameraQuery = sparrow.newQuery(database, {
    arguments = { "globalTransform" },
    inclusions = { "camera", "globalTransform" },
  })

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "body" },
    inclusions = { "body", "rider" },
  })

  return function(dt)
    cameraQuery:forEach(function(cameraEntity, globalTransform)
      riderQuery:forEach(function(riderEntity, body)
        globalTransform.position.x, globalTransform.position.y =
          body:getPosition()
      end)
    end)
  end
end

return M
