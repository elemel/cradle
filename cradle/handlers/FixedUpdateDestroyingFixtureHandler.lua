local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "externalFixture", "destroying" },
    arguments = { "externalFixture" },
    results = { "externalFixture" },
  })

  return function(dt)
    query:forEach(function(externalFixture)
      externalFixture:destroy()
      return nil
    end)
  end
end

return M
