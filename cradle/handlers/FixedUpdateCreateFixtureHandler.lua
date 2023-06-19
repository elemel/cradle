local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "body", "fixtureConfig" },
    exclusions = { "fixture" },
    arguments = { "entity", "body", "fixtureConfig" },
    results = { "fixture" },
  })

  return function(dt)
    query:forEach(function(entity, body, fixtureConfig)
      local shapeConfig = fixtureConfig.shape or {}
      local shapeType = fixtureConfig.shapeType or "rectangle"
      local shape

      if shapeType == "rectangle" then
        local x, y = unpack(shapeConfig.position or { 0, 0 })
        local width, height = unpack(shapeConfig.size or { 1, 1 })
        local angle = shapeConfig.angle or 0
        shape = love.physics.newRectangleShape(x, y, width, height, angle)
      else
        error("Invalid shape type: " .. shapeType)
      end

      local fixture = love.physics.newFixture(body, shape)
      fixture:setUserData(entity)
      return fixture
    end)
  end
end

return M
