local Class = require("cradle.Class")
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
  local selected = self.editorScreen.selectedComponent == self.component

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })
  Slab.SetLayoutColumn(1)

  if
    Slab.Text(title, {
      Color = self.editorScreen.colors.yellow,
      IsSelectable = true,
      IsSelected = selected,
    })
  then
    self.editorScreen.selectedComponent = self.component
  end

  Slab.SetLayoutColumn(2)
  local value = self.editorScreen.database:getCell(entity, self.component)

  local changed = Slab.Input(self.id .. ".value", {
    Align = "left",
    Text = value,
  })

  if changed then
    value = Slab.GetInputText()
    self.editorScreen.database:setCell(entity, self.component, value)
  end

  Slab.EndLayout()
end

return M
