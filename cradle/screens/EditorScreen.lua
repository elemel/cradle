local AddCellCommand = require("cradle.commands.AddCellCommand")
local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local DeleteRowCommand = require("cradle.commands.DeleteRowCommand")
local InsertRowCommand = require("cradle.commands.InsertRowCommand")
local nodeMod = require("cradle.node")
local RemoveCellCommand = require("cradle.commands.RemoveCellCommand")
local Slab = require("Slab")
local sparrow = require("sparrow")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  Slab.Initialize({}, true)

  self.commandHistory = {}
  self.commandFuture = {}

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

  self.constructors = {
    localTransform = function()
      return { rotation = { 1, 0 }, translation = { 0, 0 } }
    end,

    node = function()
      return {}
    end,

    title = function()
      return ""
    end,

    transform = function()
      return { rotation = { 1, 0 }, translation = { 0, 0 } }
    end,
  }

  self.sortedComponents = tableMod.keys(self.componentTitles)

  table.sort(self.sortedComponents, function(a, b)
    return self.componentTitles[a] < self.componentTitles[b]
  end)

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
  local isGuiDown = love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")

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

  if key == "y" and isGuiDown then
    if #self.commandFuture >= 1 then
      self:redoCommand()
    end
  elseif key == "z" and isGuiDown then
    if #self.commandHistory >= 1 then
      self:undoCommand()
    end
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
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height - layout.bottomDockHeight - layout.border,
    ResetLayout = false,
    W = layout.leftDockWidth - layout.border,
    X = 0,
    Y = 0,
  })

  self:updateRowsView()
  Slab.EndWindow()

  Slab.BeginWindow("rightDock", {
    AllowMove = false,
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height - layout.bottomDockHeight - layout.border,
    ResetLayout = false,
    W = layout.rightDockWidth - layout.border,
    X = layout.width - layout.rightDockWidth,
    Y = 0,
  })

  self:updateCellsView()
  Slab.EndWindow()

  Slab.BeginWindow("bottomDock", {
    AllowMove = false,
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    H = layout.bottomDockHeight - layout.border,
    ResetLayout = false,
    W = layout.width - layout.border,
    X = 0,
    Y = layout.height - layout.bottomDockHeight,
  })

  Slab.EndWindow()
end

function M:wheelmoved(...)
  Slab.OnWheelMoved(...)
end

function M:updateRowsView()
  do
    Slab.Text("Rows")

    Slab.BeginLayout("insertAndDeleteRow", { Columns = 2, ExpandW = true })
    Slab.SetLayoutColumn(1)

    if Slab.Button("Insert") then
      self:doCommand(InsertRowCommand.new(self))
    end

    Slab.SetLayoutColumn(2)
    local deleteDisabled = tableMod.count(self.selectedEntities) ~= 1

    if Slab.Button("Delete", { Disabled = deleteDisabled }) then
      local entity = next(self.selectedEntities)
      self:doCommand(DeleteRowCommand.new(self, entity))
    end

    Slab.EndLayout()
  end

  Slab.Separator()

  for entity in self.database.getNextEntity, self.database do
    local node = self.database:getCell(entity, "node")

    if node and node.parent == 0 then
      self:updateEntityNode(entity)
    end
  end
end

function M:updateEntityNode(entity)
  local title = self.database:getCell(entity, "title")
  local label = title and title ~= "" and title .. " @" .. entity
    or "@" .. entity
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

function M:updateCellsView()
  local entity = tableMod.count(self.selectedEntities) == 1
    and next(self.selectedEntities)

  if not entity then
    return
  end

  Slab.Text("Cells")

  do
    Slab.BeginLayout("addAndRemoveCell", { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("Component")

    Slab.SetLayoutColumn(2)
    local selectedLabel = self.selectedComponent
        and self.componentTitles[self.selectedComponent]
      or self.selectedComponent

    if Slab.BeginComboBox("component", { Selected = selectedLabel }) then
      for i, component in pairs(self.sortedComponents) do
        local label = self.componentTitles[component] or component
        local selected = label == selectedLabel

        if Slab.TextSelectable(label, { IsSelected = selected }) then
          self.selectedComponent = component
        end
      end

      Slab.EndComboBox()
    end

    Slab.SetLayoutColumn(1)

    local addDisabled = not self.selectedComponent
      or self.database:getCell(entity, self.selectedComponent) ~= nil

    if Slab.Button("Add", { Disabled = addDisabled }) then
      self:doCommand(AddCellCommand.new(self, entity, self.selectedComponent))
    end

    Slab.SetLayoutColumn(2)

    local removeDisabled = not self.selectedComponent
      or self.database:getCell(entity, self.selectedComponent) == nil

    if Slab.Button("Remove", { Disabled = removeDisabled }) then
      self:doCommand(
        RemoveCellCommand.new(self, entity, self.selectedComponent)
      )
    end

    Slab.EndLayout()
  end

  local archetype = self.database:getArchetype(entity)
  local sortedComponents = tableMod.keys(archetype)

  table.sort(sortedComponents, function(a, b)
    return self.componentTitles[a] < self.componentTitles[b]
  end)

  for _, component in ipairs(sortedComponents) do
    Slab.Separator()
    self:updateCellView(entity, component)
  end
end

function M:updateCellView(entity, component)
  local label = self.componentTitles[component] or component
  local selected = component == self.selectedComponent

  if component == "title" then
    Slab.BeginLayout("titleComponent", { Columns = 2, ExpandW = true })
    Slab.SetLayoutColumn(1)

    if Slab.Text(label, { IsSelectable = true, IsSelected = selected }) then
      self.selectedComponent = component
    end

    Slab.SetLayoutColumn(2)

    local changed = Slab.Input("title", {
      Align = "left",
      Text = self.database:getCell(entity, "title"),
    })

    if changed then
      self.database:setCell(entity, "title", Slab.GetInputText())
    end

    Slab.EndLayout()
  elseif component == "localTransform" or component == "transform" then
    if Slab.Text(label, { IsSelectable = true, IsSelected = selected }) then
      self.selectedComponent = component
    end

    local transform = self.database:getCell(entity, component)

    Slab.BeginLayout(component .. "Component", { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("X")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(component .. "ComponentX", {
        Align = "left",
        ReturnOnText = true,
        Text = transform.translation.x,
      })
    then
      transform.translation.x = Slab.GetInputNumber()
    end

    Slab.SetLayoutColumn(1)
    Slab.Text("Y")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(component .. "ComponentY", {
        Align = "left",
        ReturnOnText = true,
        Text = transform.translation.y,
      })
    then
      transform.translation.y = Slab.GetInputNumber()
    end

    Slab.SetLayoutColumn(1)
    Slab.Text("Angle")

    Slab.SetLayoutColumn(2)
    local angleDeg = 180
      / math.pi
      * math.atan2(transform.rotation.y, transform.rotation.x)

    if
      Slab.Input(component .. "ComponentAngle", {
        Align = "left",
        ReturnOnText = true,
        Text = angleDeg,
      })
    then
      local angleRad = Slab.GetInputNumber() * math.pi / 180

      transform.rotation.x = math.cos(angleRad)
      transform.rotation.y = math.sin(angleRad)
    end

    Slab.EndLayout()
  else
    if Slab.Text(label, { IsSelectable = true, IsSelected = selected }) then
      self.selectedComponent = component
    end
  end
end

function M:doCommand(command)
  command:redo()
  table.insert(self.commandHistory, command)
  self.commandFuture = {}
end

function M:undoCommand()
  local command = table.remove(self.commandHistory)

  if not command then
    error("Nothing to undo")
  end

  command:undo()
  table.insert(self.commandFuture, command)
end

function M:redoCommand()
  local command = table.remove(self.commandFuture)

  if not command then
    error("Nothing to redo")
  end

  command:redo()
  table.insert(self.commandHistory, command)
end

return M
