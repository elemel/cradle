local Slab = require("Slab")

local M = {}

function M.new(engine)
  return function()
    love.graphics.push("all")
    Slab.Draw()
    love.graphics.pop()
  end
end

return M
