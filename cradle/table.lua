local M = {}

function M.keys(t, result)
  result = result or {}
  local i = 1

  for k in pairs(t) do
    result[i] = k
    i = i + 1
  end

  return result
end

function M.sortedKeys(t, result)
  result = result or {}
  local i = 1

  for k in pairs(t) do
    result[i] = k
    i = i + 1
  end

  table.sort(result)
  return result
end

return M
