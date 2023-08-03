local sparrow = require("sparrow")

local M = {}

function M.new(engine)
  local database = assert(engine:getProperty("database"))
  local world = assert(engine:getProperty("world"))

  local query = sparrow.newQuery(database, {
    inclusions = { "creating", "bodyObject", "fixtureConfig", "shape" },
    exclusions = { "fixtureObject" },
    arguments = { "bodyObject", "fixtureConfig", "shape" },
    results = { "fixtureObject" },
  })

  return function(dt)
    query:forEach(function(entity, bodyObject, fixtureConfig, shape)
      local shapeType = shape.shapeType or "rectangle"
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

      if fixtureConfig.friction then
        fixtureObject:setFriction(fixtureConfig.friction)
      end

      if fixtureConfig.groupIndex then
        fixtureObject:setGroupIndex(fixtureConfig.groupIndex)
      end

      if fixtureConfig.restitution then
        fixtureObject:setRestitution(fixtureConfig.restitution)
      end

      if fixtureConfig.sensor ~= nil then
        fixtureObject:setSensor(fixtureConfig.sensor)
      end

      return fixtureObject
    end)
  end
end

return M
