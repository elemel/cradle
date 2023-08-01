local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local DrawSlabHandler = require("cradle.editor.handlers.DrawSlabHandler")
local DrawShapeHandler = require("cradle.editor.handlers.DrawShapeHandler")
local EntityTreeView = require("cradle.editor.views.EntityTreeView")
local EntityView = require("cradle.editor.views.EntityView")
local heart = require("heart")
local jsonMod = require("json")
local nodeMod = require("cradle.node")
local OrientationComponentView =
  require("cradle.editor.views.components.OrientationComponentView")
local PositionComponentView =
  require("cradle.editor.views.components.PositionComponentView")
local ShapeComponentView =
  require("cradle.editor.views.components.ShapeComponentView")
local Slab = require("Slab")
local sparrow = require("sparrow")
local StringComponentView =
  require("cradle.editor.views.components.StringComponentView")
local TagComponentView =
  require("cradle.editor.views.components.TagComponentView")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  self.database = sparrow.newDatabase()

  self.database:createColumn("body")
  self.database:createColumn("fixture")
  self.database:createColumn("joint")
  self.database:createColumn("node", "node")
  self.database:createColumn("position", "vec2")
  self.database:createColumn("orientation", "vec2")
  self.database:createColumn("shape")
  self.database:createColumn("title")

  local json = love.filesystem.read("database.json")
  local rows = jsonMod.decode(json)

  for entity, row in pairs(rows) do
    self.database:insertRow(row, entity)
  end

  self.engine = heart.newEngine()
  self.engine:setProperty("application", self.application)
  self.engine:setProperty("database", self.database)

  self.engine:addEvent("draw")
  self.engine:addEvent("keypressed")
  self.engine:addEvent("keyreleased")
  self.engine:addEvent("mousemoved")
  self.engine:addEvent("mousepressed")
  self.engine:addEvent("mousereleased")
  self.engine:addEvent("resize")
  self.engine:addEvent("textinput")
  self.engine:addEvent("update")
  self.engine:addEvent("wheelmoved")

  self.engine:addEventHandler("draw", DrawShapeHandler.new(self.engine))
  self.engine:addEventHandler("draw", DrawSlabHandler.new(self.engine))

  Slab.Initialize({}, true)

  self.commandHistory = {}
  self.commandFuture = {}

  self.componentTitles = {
    body = "Body",
    fixture = "Fixture",
    joint = "Joint",
    node = "Node",
    orientation = "Orientation",
    position = "Position",
    shape = "Shape",
    title = "Title",
  }

  self.componentConstructors = {
    body = function()
      return {}
    end,

    fixture = function()
      return {}
    end,

    joint = function()
      return {}
    end,

    node = function()
      return {}
    end,

    orientation = function()
      return { 1, 0 }
    end,

    position = function()
      return { 0, 0 }
    end,

    shape = function()
      return {
        size = { 1, 1 },
        type = "rectangle",
      }
    end,

    title = function()
      return ""
    end,
  }

  self.sortedComponents = tableMod.keys(self.componentTitles)

  table.sort(self.sortedComponents, function(a, b)
    return self.componentTitles[a] < self.componentTitles[b]
  end)

  self.selectedEntities = {}

  self.entityTreeView = EntityTreeView.new(self)
  self.entityView = EntityView.new(self)

  self.componentViews = {
    body = TagComponentView.new(self, "body"),
    fixture = TagComponentView.new(self, "fixture"),
    joint = TagComponentView.new(self, "joint"),
    node = TagComponentView.new(self, "node"),
    orientation = OrientationComponentView.new(self, "orientation"),
    position = PositionComponentView.new(self, "position"),
    shape = ShapeComponentView.new(self, "shape"),
    title = StringComponentView.new(self, "title"),
  }

  self.dragStep = 1
end

function M:handleEvent(event, ...)
  local result = self.engine:handleEvent(event, ...)

  if result then
    return result
  end

  local handler = self[event]

  if handler then
    handler(self, ...)
  end
end

function M:keypressed(key, scancode, isrepeat)
  local isGuiDown = love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")

  if key == "escape" then
    Slab.OnQuit()

    local json = self:encodeDatabaseAsJson()
    love.filesystem.write("database.json", json)

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

  self.entityTreeView:render()
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

  self.entityView:render()
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

function M:encodeDatabaseAsJson()
  local rows = {}

  for entity in self.database.getNextEntity, self.database do
    local row = self.database:getRow(entity)

    for component, value in pairs(row) do
      local valueType = self.database:getValueType(component)

      if valueType then
        value = cdefMod.encode(valueType, value)
      end

      row[component] = value
      rows[entity] = row
    end
  end

  return jsonMod.encode(rows)
end

return M
