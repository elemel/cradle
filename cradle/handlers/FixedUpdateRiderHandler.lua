local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "joint" },
    inclusions = { "joint", "rider" },
  })

  return function(dt)
    riderQuery:forEach(function(joint) end)
  end
end

return M
