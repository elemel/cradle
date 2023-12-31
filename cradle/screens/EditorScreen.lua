local cdefMod = require("cradle.cdef")
local Class = require("cradle.Class")
local DockView = require("cradle.editor.views.DockView")
local DrawSlabHandler = require("cradle.editor.handlers.DrawSlabHandler")
local DrawWorldConfigHandler =
  require("cradle.editor.handlers.DrawWorldConfigHandler")
local GameScreen = require("cradle.screens.GameScreen")
local heart = require("heart")
local jsonMod = require("json")
local nodeMod = require("cradle.node")
local Slab = require("Slab")
local sparrow = require("sparrow")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(application)
  self.application = assert(application)
  self.database = sparrow.newDatabase()

  self.database:createColumn("bodyConfig")
  self.database:createColumn("camera", "tag")
  self.database:createColumn("debugColor", "color4")
  self.database:createColumn("fixtureConfig")
  self.database:createColumn("jointConfig")
  self.database:createColumn("node", "node")
  self.database:createColumn("shapeConfig")
  self.database:createColumn("title")
  self.database:createColumn("transform", "transform")

  local json = love.filesystem.read("database.json")
  local rows = jsonMod.decode(json)

  for entity, row in pairs(rows) do
    entity = tonumber(entity)
    self.database:insertRow({}, entity)

    for component, value in pairs(row) do
      self.database:setCell(entity, component, value)
    end
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

  self.engine:addEventHandler("draw", DrawWorldConfigHandler.new(self.engine))
  self.engine:addEventHandler("draw", DrawSlabHandler.new(self.engine))

  Slab.Initialize({}, true)

  self.commandHistory = {}
  self.commandFuture = {}

  self.componentTitles = {
    camera = "Camera",
    bodyConfig = "Body Config",
    debugColor = "Debug Color",
    fixtureConfig = "Fixture Config",
    jointConfig = "Joint Config",
    node = "Node",
    shapeConfig = "Shape Config",
    title = "Title",
    transform = "Transform",
  }

  self.componentConstructors = {
    camera = function()
      return {}
    end,

    bodyConfig = function()
      return {
        type = "static",
      }
    end,

    debugColor = function()
      return { 1, 1, 1, 1 }
    end,

    fixtureConfig = function()
      return {}
    end,

    jointConfig = function()
      return {}
    end,

    node = function()
      return {}
    end,

    shapeConfig = function()
      return {
        size = { 1, 1 },
        type = "rectangle",
      }
    end,

    title = function()
      return ""
    end,

    transform = function()
      return { orientation = { 1, 0 }, position = { 0, 0 } }
    end,
  }

  self.sortedComponents = tableMod.keys(self.componentTitles)

  table.sort(self.sortedComponents, function(a, b)
    return self.componentTitles[a] < self.componentTitles[b]
  end)

  self.selectedEntities = {}

  self.leftDockView = DockView.new(self, "leftDock", "entityTree")
  self.rightDockView = DockView.new(self, "rightDock", "componentList")

  self.dragStep = 1

  self.colors = {
    blue = { 0.1, 0.6, 1, 1 },
    green = { 0.2, 1, 0.1, 1 },
    red = { 1, 0.4, 0.1, 1 },
    white = { 1, 1, 1, 1 },
    yellow = { 1, 0.9, 0.1, 1 },
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
    leftDockWidth = 300,
    rightDockWidth = 300,
    topDockHeight = 100,
    width = width,
  }

  Slab.BeginWindow("topDock", {
    AllowMove = false,
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    H = layout.topDockHeight - layout.border,
    ResetLayout = false,
    W = layout.width - layout.border,
    X = 0,
    Y = 0,
  })

  if Slab.Button("Play") then
    local json = self:encodeDatabaseAsJson()
    love.filesystem.write("database.json", json)

    application:pushScreen(GameScreen.new(application))
  end

  Slab.EndWindow()

  Slab.BeginWindow("leftDock", {
    AllowMove = false,
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height
      - layout.topDockHeight
      - layout.bottomDockHeight
      - layout.border,
    ResetLayout = false,
    W = layout.leftDockWidth - layout.border,
    X = 0,
    Y = layout.topDockHeight,
  })

  self.leftDockView:render()
  Slab.EndWindow()

  Slab.BeginWindow("rightDock", {
    AllowMove = false,
    AllowResize = true,
    AutoSizeContent = true,
    AutoSizeWindow = false,
    Border = layout.border,
    H = layout.height
      - layout.topDockHeight
      - layout.bottomDockHeight
      - layout.border,
    ResetLayout = false,
    W = layout.rightDockWidth - layout.border,
    X = layout.width - layout.rightDockWidth,
    Y = layout.topDockHeight,
  })

  self.rightDockView:render()
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
      rows[tostring(entity)] = row
    end
  end

  return jsonMod.encode(rows)
end

return M
