local ffi = require("ffi")
local sparrow = require("sparrow")
local transformMod = require("cradle.transform")

local Transform = ffi.typeof("transform")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local resources = assert(engine:getProperty("resources"))
  local images = assert(resources.images)

  local query = sparrow.newQuery(database, {
    inclusions = { "spriteConfig" },
  })

  local globalTransform = Transform()

  return function()
    love.graphics.push("all")

    local width, height = love.graphics.getDimensions()
    love.graphics.translate(0.5 * width, 0.5 * height)

    local scale = 0.1 * height
    love.graphics.scale(scale)
    love.graphics.setLineWidth(1 / scale)

    query:forEach(function(entity, spriteConfig)
      transformMod.getGlobalTransform(database, entity, globalTransform)
      love.graphics.push()
      love.graphics.translate(
        globalTransform.position.x,
        globalTransform.position.y
      )
      love.graphics.rotate(
        math.atan2(globalTransform.orientation.y, globalTransform.orientation.x)
      )

      local image = spriteConfig.filename and images[spriteConfig.filename]

      if image then
        local imageWidth, imageHeight = image:getDimensions()

        local alignmentX = 0.5
        local alignmentY = 0.5

        local originX = alignmentX * imageWidth
        local originY = alignmentY * imageHeight

        local scale = 0.01
        love.graphics.draw(image, 0, 0, 0, scale, scale, originX, originY)
      end

      love.graphics.pop()
    end)

    love.graphics.pop()
  end
end

return M
