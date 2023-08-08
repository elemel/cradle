local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    arguments = { "joint" },
    inclusions = { "joint", "rider" },
  })

  local sensitivity = 0.01

  local centerX = 0
  local centerY = -0.75

  local maxDistance = 0.25

  return function(x, y, dx, dy, istouch)
    query:forEach(function(entity, joint)
      local linearOffsetX, linearOffsetY = joint:getLinearOffset()

      linearOffsetX = linearOffsetX + dx * sensitivity
      linearOffsetY = linearOffsetY + dy * sensitivity

      if
        (centerX - linearOffsetX) * (centerX - linearOffsetX)
          + (centerY - linearOffsetY) * (centerY - linearOffsetY)
        > maxDistance * maxDistance
      then
        linearOffsetX = linearOffsetX - centerX
        linearOffsetY = linearOffsetY - centerY

        local scale = maxDistance
          / math.sqrt(
            linearOffsetX * linearOffsetX + linearOffsetY * linearOffsetY
          )

        linearOffsetX = linearOffsetX * scale
        linearOffsetY = linearOffsetY * scale

        linearOffsetX = linearOffsetX + centerX
        linearOffsetY = linearOffsetY + centerY
      end

      joint:setLinearOffset(linearOffsetX, linearOffsetY)
    end)
  end
end

return M
