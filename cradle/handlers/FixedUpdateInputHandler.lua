local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))

  local query = sparrow.newQuery(database, {
    inclusions = { "externalJoint" },
    arguments = { "externalJoint" },
  })

  return function(dt)
    local leftInput = love.keyboard.isDown("a")
    local rightInput = love.keyboard.isDown("d")

    local inputX = (rightInput and 1 or 0) - (leftInput and 1 or 0)

    query:forEach(function(externalJoint)
      externalJoint:setMotorEnabled(inputX ~= 0)
      externalJoint:setMotorSpeed(5 * 2 * math.pi * inputX)
    end)
  end
end

return M
