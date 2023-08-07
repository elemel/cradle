local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "body", "destroying" },
    arguments = { "body" },
    results = { "body" },
  })

  return function(dt)
    query:forEach(function(entity, body)
      body:destroy()
      return nil
    end)
  end
end

return M
