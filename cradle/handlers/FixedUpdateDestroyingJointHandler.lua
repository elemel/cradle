local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "joint", "destroying" },
    arguments = { "joint" },
    results = { "joint" },
  })

  return function(dt)
    query:forEach(function(entity, joint)
      joint:destroy()
      return nil
    end)
  end
end

return M
