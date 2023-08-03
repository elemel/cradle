local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "globalTransform" },
    inclusions = { "creating", "globalTransform" },
  })

  return function(dt)
    query:forEach(function(entity, globalTransform)
      transformMod.getGlobalTransform(database, entity, globalTransform)
    end)
  end
end

return M
