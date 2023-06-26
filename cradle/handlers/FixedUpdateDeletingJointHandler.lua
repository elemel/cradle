local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "externalJoint", "deleting" },
    arguments = { "externalJoint" },
    results = { "externalJoint" },
  })

  return function(dt)
    query:forEach(function(externalJoint)
      externalJoint:destroy()
      return nil
    end)
  end
end

return M