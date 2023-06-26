local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

local function getTransform(database, entity, result)
  result = result or Transform()
  transformMod.reset(result)

  local localTransform = database:getCell(entity, "localTransform")

  if not localTransform then
    local transform = database:getCell(entity, "transform")

    if transform then
      transformMod.copy(transform, result)
    end

    return result
  end

  local node = database:getCell(entity, "node")

  if not node or node.parent == 0 then
    return transformMod.copy(localTransform, result)
  end

  getTransform(database, node.parent, result)
  return transformMod.multiply(result, localTransform, result)
end

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "entity", "transform" },
    inclusions = { "creating", "localTransform", "transform" },
  })

  return function(dt)
    query:forEach(function(entity, transform)
      getTransform(database, entity, transform)
    end)
  end
end

return M
