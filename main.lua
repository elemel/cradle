local Application = require("cradle.Application")
local QuitScreen = require("cradle.screens.QuitScreen")
local TitleScreen = require("cradle.screens.TitleScreen")

function love.load()
  love.physics.setMeter(1)
  application = Application.new()
  application:pushScreen(QuitScreen.new(application))
  application:pushScreen(TitleScreen.new(application))
end

function love.update(dt) end

function love.draw() end

function love.draw(...)
  return application:handleEvent("draw", ...)
end

function love.keypressed(...)
  return application:handleEvent("keypressed", ...)
end

function love.keyreleased(...)
  return application:handleEvent("keyreleased", ...)
end

function love.mousemoved(...)
  return application:handleEvent("mousemoved", ...)
end

function love.resize(...)
  return application:handleEvent("resize", ...)
end

function love.update(...)
  return application:handleEvent("update", ...)
end
