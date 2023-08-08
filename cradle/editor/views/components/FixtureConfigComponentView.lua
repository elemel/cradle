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

  if
    Slab.Text(title, {
      Color = self.editorScreen.colors.yellow,
      IsSelectable = true,
      IsSelected = selected,
    })
  then
    self.editorScreen.selectedComponent = self.component
  end

  local fixtureConfig =
    self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Friction")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".friction", {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixtureConfig.friction or 0.2,
    })
  then
    fixtureConfig.friction = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Restitution")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".restitution", {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixtureConfig.restitution or 0,
    })
  then
    fixtureConfig.restitution = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Density")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".density", {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Step = self.editorScreen.dragStep,
      Text = fixtureConfig.density or 1,
    })
  then
    fixtureConfig.density = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Sensor")

  Slab.SetLayoutColumn(2)
  local checked = fixtureConfig.sensor or false

  if Slab.CheckBox(checked) then
    fixtureConfig.sensor = not checked
  end

  Slab.EndLayout()
end

return M
