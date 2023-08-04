local cdefMod = require("cradle.cdef")
local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "debugColor", "shape" },
    inclusions = { "shape" },
  })

  local globalTransform = Transform()

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

      transformMod.getGlobalTransform(database, entity, globalTransform)
      love.graphics.push()
      love.graphics.translate(
        globalTransform.position.x,
        globalTransform.position.y
      )
      love.graphics.rotate(
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      )

      if shape.type == "circle" then
        local radius = shape.radius or 0.5
        love.graphics.circle("line", 0, 0, radius)
        love.graphics.line(0, 0, radius, 0)
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
