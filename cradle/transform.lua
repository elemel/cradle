local cdefMod = require("cradle.cdef")
local ffi = require("ffi")

local Transform = ffi.typeof("transform")

local M = {}

function M.multiply(left, right, result)
  local x = left.position.x
    + left.orientation.x * right.position.x
    - left.orientation.y * right.position.y
  local y = left.position.y
    + left.orientation.x * right.position.y
    + left.orientation.y * right.position.x

  local re = left.orientation.x * right.orientation.x
    - left.orientation.y * right.orientation.y
  local im = left.orientation.x * right.orientation.y
    + left.orientation.y * right.orientation.x

  result = result or Transform()

  result.position.x = x
  result.position.y = y

  result.orientation.x = re
  result.orientation.y = im

  return result
end

function M.reset(result)
  result = result or Transform()

  result.position.x = 0
  result.position.y = 0

  result.orientation.x = 1
  result.orientation.y = 0

  return result
end

function M.copy(source, target)
  target = target or Transform()

  target.position = source.position
  target.orientation = source.orientation

  return result
end

return M
