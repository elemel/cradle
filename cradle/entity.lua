local M = {}

function M.format(database, entity)
  if not entity or entity == 0 then
    return nil
  end

  local title = database:getCell(entity, "title")
  return title and title .. " @" .. entity or "@" .. entity
end

function M.parse(s)
  if not s then
    return nil
  end

  local i, j = string.find(s, "@")
  return tonumber(j and string.sub(s, j + 1) or s)
end

return M
