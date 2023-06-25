local min = assert(math.min)

local M = {}

function M.new(engine)
  return function(dt)
    local clock = engine:getProperty("clock")
    clock.accumulatedDt = min(clock.accumulatedDt + dt, clock.maxAccumulatedDt)
    clock.frame = clock.frame + 1

    while clock.accumulatedDt >= clock.fixedDt do
      clock.accumulatedDt = clock.accumulatedDt - clock.fixedDt
      clock.fixedFrame = clock.fixedFrame + 1
      engine:handleEvent("fixedupdate", clock.fixedDt)
    end
  end
end

return M
