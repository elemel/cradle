local M = {}

function M.format(database, entity)
  local title = database:getCell(entity, "title")
  return title and title .. " @" .. entity or "@" .. entity
end

function M.parse(s)
  local i, j = string.find(s, "@")
  return j and tonumber(string.sub(s, j + 1)) or 0
end

return M
