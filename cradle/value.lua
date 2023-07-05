local ffi = require("ffi")

local M = {}

function M.copy(v)
  local t = type(v)

  if t == "nil" or t == "boolean" or t == "number" or t == "string" then
    return v
  elseif t == "table" then
    local v2 = {}

    for k, v3 in pairs(v) do
      v2[M.copy(k)] = M.copy(v3)
    end

    return v2
  elseif t == "cdata" then
    return ffi.typeof(v)(v)
  else
    error("Invalid type: " .. t)
  end
end

return M
