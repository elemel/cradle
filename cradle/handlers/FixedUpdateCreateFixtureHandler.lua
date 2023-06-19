local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "externalBody", "fixtureConfig" },
    exclusions = { "externalFixture" },
    arguments = { "entity", "externalBody", "fixtureConfig" },
    results = { "externalFixture" },
  })

  return function(dt)
    query:forEach(function(entity, externalBody, fixtureConfig)
      local shapeConfig = fixtureConfig.shape or {}
      local shapeType = shapeConfig.shapeType or "rectangle"
      local shape

      if shapeType == "circle" then
        local x, y = unpack(shapeConfig.position or { 0, 0 })
        local radius = shapeConfig.radius or 0.5
        shape = love.physics.newCircleShape(x, y, radius)
      elseif shapeType == "rectangle" then
        local x, y = unpack(shapeConfig.position or { 0, 0 })
        local width, height = unpack(shapeConfig.size or { 1, 1 })
        local angle = shapeConfig.angle or 0
        shape = love.physics.newRectangleShape(x, y, width, height, angle)
      else
        error("Invalid shape type: " .. shapeType)
      end

      local externalFixture = love.physics.newFixture(externalBody, shape)
      externalFixture:setUserData(entity)

      if fixtureConfig.sensor ~= nil then
        externalFixture:setSensor(fixtureConfig.sensor)
      end

      return externalFixture
    end)
  end
end

return M
