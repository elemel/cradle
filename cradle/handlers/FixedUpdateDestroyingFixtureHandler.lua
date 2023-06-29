local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "fixture", "destroying" },
    arguments = { "fixture" },
    results = { "fixture" },
  })

  return function(dt)
    query:forEach(function(fixture)
      fixture:destroy()
      return nil
    end)
  end
end

return M
