local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "deleting" },
    arguments = { "entity" },
  })

  return function(dt)
    query:forEach(function(entity)
      database:deleteRow(entity)
    end)
  end
end

return M
