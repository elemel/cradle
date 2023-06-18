local min = assert(math.min)

local M = {}

function M.new(engine)
  return function(dt)
    local clock = engine:getProperty("clock")
    clock.accumulatedDt = min(clock.accumulatedDt + dt, clock.maxAccumulatedDt)

    while clock.accumulatedDt >= clock.fixedDt do
      clock.accumulatedDt = clock.accumulatedDt - clock.fixedDt
      engine:handleEvent("fixedupdate", clock.fixedDt)
    end
  end
end

return M
