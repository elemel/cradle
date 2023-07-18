local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.id = self.component .. "Component"
  self.valueId = self.component .. "ComponentValue"
end

function M:render()
  local entity = assert(next(self.editorScreen.selectedEntities))
  local title = assert(self.editorScreen.componentTitles[self.component])
  local selected = self.editorScreen.selectedComponent == self.component

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })
  Slab.SetLayoutColumn(1)

  if Slab.Text(title, { IsSelectable = true, IsSelected = selected }) then
    self.editorScreen.selectedComponent = self.component
  end

  Slab.SetLayoutColumn(2)
  local value = self.editorScreen.database:getCell(entity, self.component)

  local changed = Slab.Input(self.valueId, {
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
