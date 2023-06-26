local cdefMod = require("cradle.cdef")
local ffi = require("ffi")

local Transform = ffi.typeof("transform")

local M = {}

function M.multiply(left, right, result)
  local x = left.translation.x
    + left.rotation.x * right.translation.x
    - left.rotation.y * right.translation.y
  local y = left.translation.y
    + left.rotation.x * right.translation.y
    + left.rotation.y * right.translation.x

  local re = left.rotation.x * right.rotation.x
    - left.rotation.y * right.rotation.y
  local im = left.rotation.x * right.rotation.y
    + left.rotation.y * right.rotation.x

  result = result or Transform()

  result.translation.x = x
  result.translation.y = y

  result.rotation.x = re
  result.rotation.y = im

  return result
end

function M.reset(result)
  result = result or Transform()

  result.translation.x = 0
  result.translation.y = 0

  result.rotation.x = 1
  result.rotation.y = 0

  return result
end

function M.copy(source, target)
  target = target or Transform()

  target.translation = source.translation
  target.rotation = source.rotation

  return result
end

return M
