local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "externalBody", "fixture", "shape" },
    exclusions = { "externalFixture" },
    arguments = { "entity", "externalBody", "fixture", "shape" },
    results = { "externalFixture" },
  })

  return function(dt)
    query:forEach(function(entity, externalBody, fixture, shape)
      local shapeType = shape.shapeType or "rectangle"
      local externalShape

      if shapeType == "circle" then
        local x, y = unpack(shape.position or { 0, 0 })
        local radius = shape.radius or 0.5
        externalShape = love.physics.newCircleShape(x, y, radius)
      elseif shapeType == "rectangle" then
        local x, y = unpack(shape.position or { 0, 0 })
        local width, height = unpack(shape.size or { 1, 1 })
        local angle = shape.angle or 0
        externalShape =
          love.physics.newRectangleShape(x, y, width, height, angle)
      else
        error("Invalid shape type: " .. shapeType)
      end

      local externalFixture =
        love.physics.newFixture(externalBody, externalShape)
      externalFixture:setUserData(entity)

      if fixture.friction then
        externalFixture:setFriction(fixture.friction)
      end

      if fixture.groupIndex then
        externalFixture:setGroupIndex(fixture.groupIndex)
      end

      if fixture.restitution then
        externalFixture:setRestitution(fixture.restitution)
      end

      if fixture.sensor ~= nil then
        externalFixture:setSensor(fixture.sensor)
      end

      return externalFixture
    end)
  end
end

return M