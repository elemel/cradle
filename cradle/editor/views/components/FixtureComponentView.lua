local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.id = self.component .. "Component"
  self.frictionId = self.component .. "ComponentFriction"
  self.restitutionId = self.component .. "ComponentRestitution"
  self.densityId = self.component .. "ComponentDensity"
end

function M:render()
  local entity = assert(next(self.editorScreen.selectedEntities))
  local title = assert(self.editorScreen.componentTitles[self.component])
  local selected = self.editorScreen.selectedComponent == self.component

  if
    Slab.Text(title, {
      Color = self.editorScreen.colors.yellow,
      IsSelectable = true,
      IsSelected = selected,
    })
  then
    self.editorScreen.selectedComponent = self.component
  end

  local fixture = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Friction")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.frictionId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixture.friction or 0.2,
    })
  then
    fixture.friction = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Restitution")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.restitutionId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixture.restitution or 0,
    })
  then
    fixture.restitution = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Density")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.densityId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixture.density or 1,
    })
  then
    fixture.density = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Sensor")

  Slab.SetLayoutColumn(2)
  local checked = fixture.sensor or false

  if Slab.CheckBox(checked) then
    fixture.sensor = not checked
  end

  Slab.EndLayout()
end

return M
