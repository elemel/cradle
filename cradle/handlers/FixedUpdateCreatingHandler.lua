local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating" },
    arguments = {},
    results = { "creating" },
  })

  return function(dt)
    query:forEach(function(entity)
      return nil
    end)
  end
end

return M
