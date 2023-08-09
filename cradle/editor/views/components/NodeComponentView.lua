local Class = require("cradle.Class")
local entityMod = require("cradle.entity")
local nodeMod = require("cradle.node")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, component)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.component = assert(component)
end

function M:render()
  local entity = assert(next(self.editorScreen.selectedEntities))
  local title = assert(self.editorScreen.componentTitles[self.component])
  local selected = self.component == self.editorScreen.selectedComponent

  if
    Slab.Text(title, {
      Color = self.editorScreen.colors.yellow,
      IsSelectable = true,
      IsSelected = selected,
    })
  then
    self.editorScreen.selectedComponent = self.component
  end

  local node = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Parent")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".parent", {
      Align = "left",
      ReturnOnText = false,
      Text = entityMod.format(self.editorScreen.database, node.parent or 0),
    })
  then
    local parent = entityMod.parse(Slab.GetInputText())
    nodeMod.setParent(self.editorScreen.database, entity, parent)
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Previous Sibling")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".previousSibling", {
      Align = "left",
      ReturnOnText = true,
      Text = entityMod.format(
        self.editorScreen.database,
        node.previousSibling or 0
      ),
    })
  then
    -- node.previousSibling = entityMod.parse(Slab.GetInputText())
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Next Sibling")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".nextSibling", {
      Align = "left",
      ReturnOnText = true,
      Text = entityMod.format(
        self.editorScreen.database,
        node.nextSibling or 0
      ),
    })
  then
    -- node.nextSibling = entityMod.parse(Slab.GetInputText())
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("First Child")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".alpha", {
      Align = "left",
      ReturnOnText = true,
      Text = entityMod.format(self.editorScreen.database, node.firstChild or 0),
    })
  then
    -- node.firstChild = entityMod.parse(Slab.GetInputText())
  end

  Slab.EndLayout()
end

return M
