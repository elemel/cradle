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
      local shape = love.physics.newRectangleShape(1, 1)
      local fixture = love.physics.newFixture(body, shape)
      fixture:setUserData(entity)
      return fixture
    end)
  end
end

return M
