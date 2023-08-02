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

  local transform = Transform()
  transformMod.reset(transform)

  local position = database:getCell(entity, "position")

  if position then
    transform.position = position
  end

  local orientation = database:getCell(entity, "orientation")

  if orientation then
    transform.orientation = orientation
  end

  return transformMod.multiply(result, transform, result)
end

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "debugColor", "shape" },
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

    query:forEach(function(entity, debugColor, shape)
      if debugColor then
        love.graphics.setColor(
          debugColor.red,
          debugColor.green,
          debugColor.blue,
          debugColor.alpha
        )
      else
        love.graphics.setColor(1, 1, 1, 1)
      end

      getWorldTransform(database, entity, worldTransform)
      love.graphics.push()
      love.graphics.translate(
        worldTransform.position.x,
        worldTransform.position.y
      )
      love.graphics.rotate(
        math.atan2(worldTransform.orientation.y, worldTransform.orientation.x)
      )

      if shape.type == "circle" then
        local radius = shape.radius or 0.5
        love.graphics.circle("line", 0, 0, radius)
      elseif shape.type == "rectangle" then
        love.graphics.rectangle(
          "line",
          -0.5 * shape.size[1],
          -0.5 * shape.size[2],
          shape.size[1],
          shape.size[2]
        )
      else
        error("Invalid shape type: " .. shape.type)
      end

      love.graphics.pop()
    end)

    love.graphics.pop()
  end
end

return M
