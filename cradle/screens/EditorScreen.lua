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

  self.database:createColumn("localTransform", "transform")
  self.database:createColumn("node", "node")
  self.database:createColumn("title")
  self.database:createColumn("transform", "transform")

  self.componentTitles = {
    localTransform = "Local Transform",
    node = "Node",
    title = "Title",
    transform = "Transform",
  }

  local entity1 = self.database:insertRow({
    localTransform = { rotation = { 1, 0 } },
    node = {},
    title = "A",
    transform = {},
  })

  local entity2 = self.database:insertRow({
    localTransform = { rotation = { 1, 0 } },
    node = {},
    title = "B",
    transform = {},
  })

  local entity3 = self.database:insertRow({
    localTransform = { rotation = { 1, 0 } },
    node = {},
    title = "C",
    transform = {},
  })

  local entity4 = self.database:insertRow({
    localTransform = { rotation = { 1, 0 } },
    node = {},
    title = "D",
    transform = {},
  })

  nodeMod.setParent(self.database, entity2, entity1)
  nodeMod.setParent(self.database, entity3, entity2)
  nodeMod.setParent(self.database, entity4, entity1)

  self.selectedEntities = {}
  self.selectedComponents = {}
end

function M:handleEvent(event, ...)
  local handler = self[event]

  if handler then
    handler(self, ...)
  end
end

function M:draw()
  love.graphics.push("all")
  love.graphics.clear()
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
    ContentW = layout.rightDockWidth - layout.border,
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
  Slab.Text("Entities")
  Slab.Separator()

  for entity in self.database.getNextEntity, self.database do
    local node = self.database:getCell(entity, "node")

    if node and node.parent == 0 then
      self:updateEntityNode(entity)
    end
  end
end

function M:updateEntityNode(entity)
  local label = self.database:getCell(entity, "title") or "Entity " .. entity
  local node = self.database:getCell(entity, "node")
  local leaf = node.firstChild == 0
  local selected = self.selectedEntities[entity] or false

  local open = Slab.BeginTree("entity" .. entity, {
    IsLeaf = leaf,
    IsSelected = selected,
    Label = label,
    OpenWithHighlight = false,
  })

  if Slab.IsControlClicked() then
    tableMod.clear(self.selectedEntities)
    self.selectedEntities[entity] = true
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
  local entity = tableMod.count(self.selectedEntities) == 1
    and next(self.selectedEntities)

  if not entity then
    return
  end

  Slab.Text("Components")

  local archetype = self.database:getArchetype(entity)
  local sortedComponents = tableMod.sortedKeys(archetype)

  for _, component in ipairs(sortedComponents) do
    Slab.Separator()
    local label = self.componentTitles[component] or component
    local selected = self.selectedComponents[component] or false

    if Slab.Text(label, { IsSelectable = true, IsSelected = selected }) then
      tableMod.clear(self.selectedComponents)
      self.selectedComponents[component] = true
      selected = true
    end

    if component == "title" then
      local changed = Slab.Input("title", {
        Align = "left",
        Text = self.database:getCell(entity, "title"),
        W = 192,
      })

      if changed then
        self.database:setCell(entity, "title", Slab.GetInputText())
      end
    end
  end
end

return M
