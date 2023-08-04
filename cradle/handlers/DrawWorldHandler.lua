local sparrow = require("sparrow")
local M = {}

function M.new(engine, config)
  config = config or {}
  local database = engine:getProperty("database")
  local world = engine:getProperty("world")
  local drawMode = config.drawMode or "line"

  local cameraQuery = sparrow.newQuery(database, {
    arguments = { "globalTransform" },
    inclusions = { "camera", "globalTransform" },
  })

  local fixtureQuery = sparrow.newQuery(database, {
    arguments = { "debugColor", "fixtureObject" },
    inclusions = { "fixtureObject" },
  })

  return function()
    cameraQuery:forEach(function(cameraEntity, globalTransform)
      love.graphics.push("all")

      local width, height = love.graphics.getDimensions()
      love.graphics.translate(0.5 * width, 0.5 * height)

      local scale = 0.1 * height
      love.graphics.scale(scale)
      love.graphics.setLineWidth(1 / scale)

      local angle =
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      love.graphics.rotate(-angle)

      love.graphics.translate(
        -globalTransform.position.x,
        -globalTransform.position.y
      )

      fixtureQuery:forEach(function(fixtureEntity, debugColor, fixtureObject)
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

        local bodyObject = fixtureObject:getBody()
        local shapeObject = fixtureObject:getShape()
        local shapeType = shapeObject:getType()

        if shapeType == "circle" then
          local localX, localY = shapeObject:getPoint()
          local radius = shapeObject:getRadius()

          local x1, y1 = bodyObject:getWorldPoint(localX, localY)
          local x2, y2 = bodyObject:getWorldPoint(localX + radius, localY)

          love.graphics.circle(drawMode, x1, y1, radius)
          love.graphics.line(x1, y1, x2, y2)
        elseif shapeType == "polygon" then
          love.graphics.polygon(
            drawMode,
            bodyObject:getWorldPoints(shapeObject:getPoints())
          )
        else
          error("Invalid shape type: " .. shapeType)
        end
      end)

      love.graphics.pop()
    end)
  end
end

return M
