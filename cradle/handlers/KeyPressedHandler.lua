local M = {}

function M.new(engine)
  local application = assert(engine:getProperty("application"))

  return function(key, scancode, isrepeat)
    if key == "escape" then
      application:popScreen()
      local screen = application:peekScreen()

      if screen then
        local width, height = love.graphics.getDimensions()
        screen:handleEvent("resize", width, height)
      end
    end
  end
end

return M
