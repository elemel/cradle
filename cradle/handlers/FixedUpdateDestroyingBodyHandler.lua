local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "bodyObject", "destroying" },
    arguments = { "bodyObject" },
    results = { "bodyObject" },
  })

  return function(dt)
    query:forEach(function(entity, bodyObject)
      bodyObject:destroy()
      return nil
    end)
  end
end

return M
