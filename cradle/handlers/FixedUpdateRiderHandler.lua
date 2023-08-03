local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "jointObject" },
    inclusions = { "jointObject", "rider" },
  })

  return function(dt)
    riderQuery:forEach(function(entity, jointObject) end)
  end
end

return M
