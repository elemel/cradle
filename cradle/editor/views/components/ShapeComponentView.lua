local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.shapeTypes = { "circle", "polygon", "rectangle" }
  self.shapeTypeTitles =
    { circle = "Circle", polygon = "Polygon", rectangle = "Rectangle" }

  self.heightId = self.component .. "ComponentHeight"
  self.id = self.component .. "Component"
  self.radiusId = self.component .. "ComponentRadius"
  self.typeId = self.component .. "ComponentType"
  self.widthId = self.component .. "ComponentWidth"
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

  local shape = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedShapeTypeTitle = shape.type and self.shapeTypeTitles[shape.type]

  if Slab.BeginComboBox(self.typeId, { Selected = selectedShapeTypeTitle }) then
    for i, shapeType in pairs(self.shapeTypes) do
      local shapeTypeTitle = shapeType and self.shapeTypeTitles[shapeType]
      local selected = selectedShapeTypeTitle == shapeTypeTitle

      if Slab.TextSelectable(shapeTypeTitle, { IsSelected = selected }) then
        shape.type = shapeType
      end
    end

    Slab.EndComboBox()
  end

  if shape.type == "circle" then
    Slab.SetLayoutColumn(1)
    Slab.Text("Radius")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.radiusId, {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shape.radius or 0.5,
      })
    then
      shape.radius = Slab.GetInputNumber()
    end
  elseif shape.type == "rectangle" then
    Slab.SetLayoutColumn(1)
    Slab.Text("Width")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.widthId, {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shape.size and shape.size[1] or 1,
      })
    then
      shape.size = shape.size or { 1, 1 }
      shape.size[1] = Slab.GetInputNumber()
    end

    Slab.SetLayoutColumn(1)
    Slab.Text("Height")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.heightId, {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shape.size and shape.size[2] or 1,
      })
    then
      shape.size = shape.size or { 1, 1 }
      shape.size[2] = Slab.GetInputNumber()
    end
  end

  Slab.EndLayout()
end

return M
