local Class = require("cradle.Class")

local floor = assert(math.floor)
local insert = assert(table.insert)
local remove = assert(table.remove)

local M = Class.new()

function M:init(application, config)
  self.application = assert(application)
  self.title = assert(config.title)
  self.options = assert(config.options)
  self.selectedOptionIndex = 1
end

function M:handleEvent(event, ...)
  local handler = self[event]

  if handler then
    handler(self, ...)
  end
end

function M:draw()
  love.graphics.push("all")
  local screenWidth, screenHeight = love.graphics.getDimensions()

  local optionFontSize = screenHeight / 20
  local optionFont = self.application:getFont(floor(optionFontSize))
  local optionHeight = optionFont:getHeight()

  local titleFontSize = optionFontSize * 1.5
  local titleFont = self.application:getFont(floor(titleFontSize))
  local titleHeight = titleFont:getHeight()

  local blankHeight = 0.5 * optionHeight
  local totalHeight = titleHeight + blankHeight + optionHeight * #self.options

  local centerX = 0.5 * screenWidth
  local centerY = 0.5 * screenHeight

  love.graphics.setFont(titleFont)

  local titleX = centerX - 0.5 * titleFont:getWidth(self.title)
  local titleY = centerY - 0.5 * totalHeight

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.title, floor(titleX), floor(titleY))

  love.graphics.setFont(optionFont)

  for i, option in ipairs(self.options) do
    if i == self.selectedOptionIndex then
      love.graphics.setColor(0, 1, 0)
    else
      love.graphics.setColor(1, 1, 1)
    end

    local optionX = centerX - 0.5 * optionFont:getWidth(option.title)
    local optionY = centerY
      - 0.5 * totalHeight
      + titleHeight
      + blankHeight
      + (i - 1) * optionHeight

    love.graphics.print(option.title, floor(optionX), floor(optionY))
  end

  love.graphics.pop()
end

function M:keypressed(key, scancode, isrepeat)
  if key == "down" then
    self.selectedOptionIndex = self.selectedOptionIndex % #self.options + 1
  elseif key == "up" then
    self.selectedOptionIndex = (self.selectedOptionIndex - 2) % #self.options
      + 1
  elseif key == "return" then
    local option = self.options[self.selectedOptionIndex]
    option.handler()
  end
end

return M
