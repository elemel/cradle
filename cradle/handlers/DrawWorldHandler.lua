local sparrow = require("sparrow")
local M = {}

function M.new(engine, config)
  config = config or {}
  local world = engine:getProperty("world")
  local drawMode = config.drawMode or "line"

  return function()
    love.graphics.push("all")

    local width, height = love.graphics.getDimensions()
    love.graphics.translate(0.5 * width, 0.5 * height)
    local scale = 0.1 * height
    love.graphics.scale(scale)
    love.graphics.setLineWidth(1 / scale)

    for _, body in ipairs(world:getBodies()) do
      for _, fixture in ipairs(body:getFixtures()) do
        local shape = fixture:getShape()
        local shapeType = shape:getType()

        if shapeType == "circle" then
          local localX, localY = shape:getPoint()
          local radius = shape:getRadius()

          local x1, y1 = body:getWorldPoint(localX, localY)
          local x2, y2 = body:getWorldPoint(localX + radius, localY)

          love.graphics.circle(drawMode, x1, y1, radius)
          love.graphics.line(x1, y1, x2, y2)
        elseif shapeType == "polygon" then
          love.graphics.polygon(
            drawMode,
            body:getWorldPoints(shape:getPoints())
          )
        end
      end
    end

    love.graphics.pop()
  end
end

return M