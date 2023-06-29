local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local riderQuery = sparrow.newQuery(database, {
    arguments = { "externalJoint" },
    inclusions = { "externalJoint", "rider" },
  })

  return function(dt)
    riderQuery:forEach(function(externalJoint) end)
  end
end

return M
