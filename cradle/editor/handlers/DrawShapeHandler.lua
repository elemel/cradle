local cdefMod = require("cradle.cdef")
local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

local function getWorldTransform(database, entity, result)
  result = result or Transform()
  local node = database:getCell(entity, "node")

  if node and node.parent ~= 0 then
    getWorldTransform(database, node.parent, result)
  else
    transformMod.reset(result)
  end

  local transform = database:getCell(entity, "transform")

  if transform then
    transformMod.multiply(result, transform, result)
  end

  return result
end

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "entity", "shape" },
    inclusions = { "shape" },
  })

  local worldTransform = Transform()

  return function()
    love.graphics.push("all")

    local width, height = love.graphics.getDimensions()
    love.graphics.translate(0.5 * width, 0.5 * height)

    local scale = 0.1 * height
    love.graphics.scale(scale)
    love.graphics.setLineWidth(1 / scale)

    query:forEach(function(entity, shape)
      getWorldTransform(database, entity, worldTransform)
      love.graphics.push()
      love.graphics.translate(
        worldTransform.translation.x,
        worldTransform.translation.y
      )
      love.graphics.rotate(
        math.atan2(worldTransform.rotation.y, worldTransform.rotation.x)
      )

      if shape.type == "rectangle" then
        love.graphics.rectangle(
          "line",
          -0.5 * shape.size[1],
          -0.5 * shape.size[2],
          shape.size[1],
          shape.size[2]
        )
      end

      love.graphics.pop()
    end)

    love.graphics.pop()
  end
end

return M
