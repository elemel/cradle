local M = {}

function M.new(engine)
  return function(dt)
    local world = engine:getProperty("world")
    world:update(dt)
  end
end

return M
