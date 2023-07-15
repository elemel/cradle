local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen)
  self.editorScreen = assert(editorScreen)
  self.title = assert(self.editorScreen.componentTitles.shape)

  self.shapeTypes = { "circle", "polygon", "rectangle" }
  self.shapeTypeTitles =
    { circle = "Circle", polygon = "Polygon", rectangle = "Rectangle" }
end

function M:render()
  local entity = assert(next(self.editorScreen.selectedEntities))
  local selected = self.editorScreen.selectedComponent == "shape"

  if Slab.Text(self.title, { IsSelectable = true, IsSelected = selected }) then
    self.editorScreen.selectedComponent = "shape"
  end

  local shape = self.editorScreen.database:getCell(entity, "shape")

  Slab.BeginLayout("shapeComponent", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedShapeTypeTitle = shape.type and self.shapeTypeTitles[shape.type]

  if
    Slab.BeginComboBox(
      "shapeComponentType",
      { Selected = selectedShapeTypeTitle }
    )
  then
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
      Slab.Input("shapeComponentRadius", {
        Align = "left",
        ReturnOnText = true,
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
      Slab.Input("shapeComponentWidth", {
        Align = "left",
        ReturnOnText = true,
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
      Slab.Input("shapeComponentHeight", {
        Align = "left",
        ReturnOnText = true,
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
