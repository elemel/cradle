local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "bodyObject", "fixture", "shape" },
    exclusions = { "fixtureObject" },
    arguments = { "bodyObject", "fixture", "shape" },
    results = { "fixtureObject" },
  })

  return function(dt)
    query:forEach(function(entity, bodyObject, fixture, shape)
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

      local fixtureObject = love.physics.newFixture(bodyObject, shapeObject)
      fixtureObject:setUserData(entity)

      if fixture.friction then
        fixtureObject:setFriction(fixture.friction)
      end

      if fixture.groupIndex then
        fixtureObject:setGroupIndex(fixture.groupIndex)
      end

      if fixture.restitution then
        fixtureObject:setRestitution(fixture.restitution)
      end

      if fixture.sensor ~= nil then
        fixtureObject:setSensor(fixture.sensor)
      end

      return fixtureObject
    end)
  end
end

return M
