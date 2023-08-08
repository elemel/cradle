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

  local color = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Red", { Color = self.editorScreen.colors.red })

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".red", {
      Align = "left",
      MaxNumber = 1,
      MinNumber = 0,
      NumbersOnly = true,
      ReturnOnText = true,
      Text = color.red,
      UseSlider = true,
    })
  then
    color.red = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Green", { Color = self.editorScreen.colors.green })

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".green", {
      Align = "left",
      MaxNumber = 1,
      MinNumber = 0,
      NumbersOnly = true,
      ReturnOnText = true,
      Text = color.green,
      UseSlider = true,
    })
  then
    color.green = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Blue", { Color = self.editorScreen.colors.blue })

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".blue", {
      Align = "left",
      MaxNumber = 1,
      MinNumber = 0,
      NumbersOnly = true,
      ReturnOnText = true,
      Text = color.blue,
      UseSlider = true,
    })
  then
    color.blue = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Alpha")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".alpha", {
      Align = "left",
      MaxNumber = 1,
      MinNumber = 0,
      NumbersOnly = true,
      ReturnOnText = true,
      Text = color.alpha,
      UseSlider = true,
    })
  then
    color.alpha = Slab.GetInputNumber()
  end

  Slab.EndLayout()
end

return M
