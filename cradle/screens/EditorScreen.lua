local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local DrawSlabHandler = require("cradle.editor.handlers.DrawSlabHandler")
local EntityTreeView = require("cradle.editor.views.EntityTreeView")
local EntityView = require("cradle.editor.views.EntityView")
local heart = require("heart")
local nodeMod = require("cradle.node")
local ShapeComponentView =
  require("cradle.editor.views.components.ShapeComponentView")
local Slab = require("Slab")
local sparrow = require("sparrow")
local StringComponentView =
  require("cradle.editor.views.components.StringComponentView")
local TagComponentView =
  require("cradle.editor.views.components.TagComponentView")
local TransformComponentView =
  require("cradle.editor.views.components.TransformComponentView")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(application)
  self.application = assert(application)

  self.engine = heart.newEngine()
  self.engine:setProperty("application", self.application)

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

  self.engine:addEventHandler("draw", DrawSlabHandler.new(self.engine))

  Slab.Initialize({}, true)

  self.commandHistory = {}
  self.commandFuture = {}

  self.database = sparrow.newDatabase()

  self.database:createColumn("body")
  self.database:createColumn("fixture")
  self.database:createColumn("joint")
  self.database:createColumn("node", "node")
  self.database:createColumn("shape")
  self.database:createColumn("title")
  self.database:createColumn("transform", "transform")

  self.componentTitles = {
    body = "Body",
    fixture = "Fixture",
    joint = "Joint",
    node = "Node",
    shape = "Shape",
    title = "Title",
    transform = "Transform",
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

    shape = function()
      return {
        size = { 1, 1 },
        type = "rectangle",
      }
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
    node = {},
    title = "A",
    transform = { rotation = { 1, 0 } },
  })

  local entity2 = self.database:insertRow({
    node = {},
    title = "B",
    transform = { rotation = { 1, 0 } },
  })

  local entity3 = self.database:insertRow({
    node = {},
    title = "C",
    transform = { rotation = { 1, 0 } },
  })

  local entity4 = self.database:insertRow({
    node = {},
    title = "D",
    transform = { rotation = { 1, 0 } },
  })

  nodeMod.setParent(self.database, entity2, entity1)
  nodeMod.setParent(self.database, entity3, entity2)
  nodeMod.setParent(self.database, entity4, entity1)

  self.selectedEntities = {}

  self.entityTreeView = EntityTreeView.new(self)
  self.entityView = EntityView.new(self)

  self.componentViews = {
    body = TagComponentView.new(self, "body"),
    fixture = TagComponentView.new(self, "fixture"),
    joint = TagComponentView.new(self, "joint"),
    node = TagComponentView.new(self, "node"),
    shape = ShapeComponentView.new(self, "shape"),
    title = StringComponentView.new(self, "title"),
    transform = TransformComponentView.new(self, "transform"),
  }
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

return M
