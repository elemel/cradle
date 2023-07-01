local M = {}

function M.new(engine)
  local application = assert(engine:getProperty("application"))

  return function(key, scancode, isrepeat)
    if key == "escape" then
      local width, height = love.graphics.getDimensions()
      love.mouse.setPosition(0.75 * width, 0.75 * height)
      love.mouse.setRelativeMode(false)

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
