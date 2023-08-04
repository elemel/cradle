local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "fixtureObject", "destroying" },
    arguments = { "fixtureObject" },
    results = { "fixtureObject" },
  })

  return function(dt)
    query:forEach(function(entity, fixtureObject)
      fixtureObject:destroy()
      return nil
    end)
  end
end

return M
