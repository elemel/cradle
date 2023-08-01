local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.id = self.component .. "Component"
  self.angleId = self.component .. "ComponentAngle"
end

function M:render()
  local entity = assert(next(self.editorScreen.selectedEntities))
  local title = assert(self.editorScreen.componentTitles[self.component])
  local selected = self.component == self.editorScreen.selectedComponent

  local orientation = self.editorScreen.database:getCell(entity, self.component)
  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })
  Slab.SetLayoutColumn(1)

  if Slab.Text(title, { IsSelectable = true, IsSelected = selected }) then
    self.editorScreen.selectedComponent = self.component
  end

  Slab.SetLayoutColumn(2)
  local angleDeg = 180 / math.pi * math.atan2(orientation.y, orientation.x)

  if
    Slab.Input(self.angleId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = angleDeg,
    })
  then
    local angleRad = Slab.GetInputNumber() * math.pi / 180

    orientation.x = math.cos(angleRad)
    orientation.y = math.sin(angleRad)
  end

  Slab.EndLayout()
end

return M