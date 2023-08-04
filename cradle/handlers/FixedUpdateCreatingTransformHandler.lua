local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = {},
    exclusions = { "globalTransform" },
    inclusions = { "creating", "transform" },
    results = { "globalTransform" },
  })

  return function(dt)
    query:forEach(function(entity)
      return transformMod.getGlobalTransform(database, entity)
    end)
  end
end

return M
