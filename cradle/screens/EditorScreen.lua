local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local nodeMod = require("cradle.node")
local Slab = require("Slab")
local sparrow = require("sparrow")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  Slab.Initialize({}, true)
  self.database = sparrow.newDatabase()

  self.database:createColumn("label")
  self.database:createColumn("localTransform", "transform")
  self.database:createColumn("node", "node")
  self.database:createColumn("transform", "transform")
  self.database:createColumn("selected", "tag")

  self.selectedQuery = sparrow.newQuery(self.database, {
    arguments = { "entity" },
    inclusions = { "selected" },
  })

  local entity1 = self.database:insertRow({
    label = "A",
    localTransform = { rotation = { 1, 0 } },
    node = {},
    transform = {},
  })

  local entity2 = self.database:insertRow({
    label = "B",
    localTransform = { rotation = { 1, 0 } },
    node = {},
    transform = {},
  })

  local entity3 = self.database:insertRow({
    label = "C",
    localTransform = { rotation = { 1, 0 } },
    node = {},
    transform = {},
  })

  local entity4 = self.database:insertRow({
    label = "D",
    localTransform = { rotation = { 1, 0 } },
    node = {},
    transform = {},
  })

  nodeMod.setParent(self.database, entity2, entity1)
  nodeMod.setParent(self.database, entity3, entity2)
  nodeMod.setParent(self.database, entity4, entity1)
end

function M:handleEvent(event, ...)
  local handler = self[event]

  if handler then
    handler(self, ...)
  end
end

function M:draw()
  love.graphics.push("all")
  Slab.Draw()
  love.graphics.pop()
end

function M:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    Slab.OnQuit()

    self.application:popScreen()
    local screen = application:peekScreen()

    if screen then
      local width, height = love.graphics.getDimensions()
      screen:handleEvent("resize", width, height)
    end

    return
  end

  Slab.OnKeyPressed(key, scancode, isrepeat)
end

function M:keyreleased(...)
  Slab.OnKeyReleased(...)
end

function M:mousemoved(...)
  Slab.OnMouseMoved(...)
end

function M:mousepressed(...)
  Slab.OnMousePressed(...)
end

function M:mousereleased(...)
  Slab.OnMouseReleased(...)
end

function M:textinput(...)
  Slab.OnTextInput(...)
end

function M:update(dt)
  Slab.Update(dt)
  local width, height = love.graphics.getDimensions()

  local layout = {
    border = 4,
    bottomDockHeight = 100,
    height = height,
    leftDockWidth = 200,
    rightDockWidth = 200,
    width = width,
  }

  Slab.BeginWindow("leftDock", {
    AllowMove = false,
    AllowResize = false,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height - layout.bottomDockHeight - layout.border,
    ResetLayout = true,
    ShowMinimize = false,
    W = layout.leftDockWidth - layout.border,
    X = 0,
    Y = 0,
  })

  self:updateEntityTree()
  Slab.EndWindow()

  Slab.BeginWindow("rightDock", {
    AllowMove = false,
    AllowResize = false,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height - layout.bottomDockHeight - layout.border,
    ResetLayout = true,
    ShowMinimize = false,
    W = layout.rightDockWidth - layout.border,
    X = layout.width - layout.rightDockWidth,
    Y = 0,
  })

  self:updateComponentList()
  Slab.EndWindow()

  Slab.BeginWindow("bottomDock", {
    AllowMove = false,
    AllowResize = false,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.bottomDockHeight - layout.border,
    ResetLayout = true,
    ShowMinimize = false,
    W = layout.width - layout.border,
    X = 0,
    Y = layout.height - layout.bottomDockHeight,
  })

  Slab.EndWindow()
end

function M:wheelmoved(...)
  Slab.OnWheelMoved(...)
end

function M:updateEntityTree()
  for entity in self.database.getNextEntity, self.database do
    local node = self.database:getCell(entity, "node")

    if node and node.parent == 0 then
      self:updateEntityNode(entity)
    end
  end
end

function M:updateEntityNode(entity)
  local label = self.database:getCell(entity, "label") or "Entity " .. entity
  local node = self.database:getCell(entity, "node")
  local leaf = node.firstChild == 0
  local selected = self.database:containsCell(entity, "selected")

  local open = Slab.BeginTree("entity" .. entity, {
    IsLeaf = leaf,
    IsSelected = selected,
    Label = label,
    OpenWithHighlight = false,
  })

  if Slab.IsControlClicked() then
    self.selectedQuery:forEach(function(selectedEntity)
      self.database:setCell(selectedEntity, "selected", nil)
    end)

    self.database:setCell(entity, "selected", {})
    selected = true
  end

  if open then
    if not leaf then
      local childEntity = node.firstChild

      repeat
        self:updateEntityNode(childEntity, selectedEntitites)

        local childNode = self.database:getCell(childEntity, "node")
        childEntity = childNode.nextSibling
      until childEntity == node.firstChild
    end

    Slab.EndTree()
  end
end

function M:updateComponentList()
  local selectedEntity = self:getSelectedEntity()

  if not selectedEntity then
    return
  end

  local archetype = self.database:getArchetype(selectedEntity)
  local sortedComponents = tableMod.sortedKeys(archetype)

  for _, component in ipairs(sortedComponents) do
    Slab.Text(component)
  end
end

function M:getSelectedEntity()
  local count = 0
  local result

  self.selectedQuery:forEach(function(entity)
    count = count + 1
    result = entity
  end)

  return count == 1 and result or nil
end

function M:getSelectedEntities(result)
  result = result or {}

  self.selectedQuery:forEach(function(entity)
    result[entity] = true
  end)

  return result
end

return M
