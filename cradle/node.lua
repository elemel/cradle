local M = {}

function M.setParent(database, entity, parent)
  parent = parent or 0
  local node = assert(database:getCell(entity, "node"))

  if parent ~= node.parent then
    if node.parent ~= 0 then
      local parentNode = assert(database:getCell(node.parent, "node"))

      if node.nextSibling == entity then
        assert(node.previousSibling == entity)
        assert(parentNode.firstChild == entity)
        parentNode.firstChild = 0
      else
        if parentNode.firstChild == entity then
          parentNode.firstChild = node.nextSibling
        end

        local previousNode = database:getCell(node.previousSibling, "node")
        local nextNode = database:getCell(node.nextSibling, "node")

        previousNode.nextSibling = node.nextSibling
        nextNode.previousSibling = node.previousSibling
      end

      node.parent = 0
      node.previousSibling = 0
      node.nextSibling = 0
    end

    if parent ~= 0 then
      local parentNode = assert(database:getCell(parent, "node"))

      if parentNode.firstChild == 0 then
        parentNode.firstChild = entity
        node.parent = parent

        node.previousSibling = entity
        node.nextSibling = entity
      else
        local nextSibling = parentNode.firstChild
        local nextNode = assert(database:getCell(nextSibling, "node"))
        assert(nextNode.parent == parent)

        local previousSibling = nextNode.previousSibling
        local previousNode = assert(database:getCell(previousSibling, "node"))
        assert(previousNode.parent == parent)

        node.parent = parent

        previousNode.nextSibling = entity
        node.previousSibling = previousSibling

        node.nextSibling = nextSibling
        nextNode.previousSibling = entity
      end
    end
  end
end

return M
