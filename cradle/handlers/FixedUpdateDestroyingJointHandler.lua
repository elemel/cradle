local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "jointObject", "destroying" },
    arguments = { "jointObject" },
    results = { "jointObject" },
  })

  return function(dt)
    query:forEach(function(entity, jointObject)
      jointObject:destroy()
      return nil
    end)
  end
end

return M
