local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "body", "fixtureConfig", "shape" },
    exclusions = { "fixture" },
    arguments = { "body", "fixtureConfig", "shape" },
    results = { "fixture" },
  })

  return function(dt)
    query:forEach(function(entity, body, fixtureConfig, shape)
      local shapeType = shape.type or "rectangle"
      local shapeObject

      if shapeType == "circle" then
        local x, y = unpack(shape.position or { 0, 0 })
        local radius = shape.radius or 0.5
        shapeObject = love.physics.newCircleShape(x, y, radius)
      elseif shapeType == "rectangle" then
        local x, y = unpack(shape.position or { 0, 0 })
        local width, height = unpack(shape.size or { 1, 1 })
        local angle = shape.angle or 0
        shapeObject = love.physics.newRectangleShape(x, y, width, height, angle)
      else
        error("Invalid shape type: " .. shapeType)
      end

      local density = fixtureConfig.density or 1
      local fixture = love.physics.newFixture(body, shapeObject, density)
      fixture:setUserData(entity)

      if fixtureConfig.friction then
        fixture:setFriction(fixtureConfig.friction)
      end

      if fixtureConfig.groupIndex then
        fixture:setGroupIndex(fixtureConfig.groupIndex)
      end

      if fixtureConfig.restitution then
        fixture:setRestitution(fixtureConfig.restitution)
      end

      if fixtureConfig.sensor ~= nil then
        fixture:setSensor(fixtureConfig.sensor)
      end

      return fixture
    end)
  end
end

return M
