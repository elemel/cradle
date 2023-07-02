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

function M.count(t)
  local result = 0

  for k in pairs(t) do
    result = result + 1
  end

  return result
end

function M.clear(t)
  for k in pairs(t) do
    t[k] = nil
  end
end

return M
