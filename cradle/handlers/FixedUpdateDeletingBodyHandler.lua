local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "externalBody", "deleting" },
    arguments = { "externalBody" },
    results = { "externalBody" },
  })

  return function(dt)
    query:forEach(function(externalBody)
      externalBody:destroy()
      return nil
    end)
  end
end

return M
