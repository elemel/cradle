local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, component)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.component = assert(component)

  self.shapeTypes = { "circle", "polygon", "rectangle" }
  self.shapeTypeTitles =
    { circle = "Circle", polygon = "Polygon", rectangle = "Rectangle" }
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

  local shapeConfig = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedShapeTypeTitle = shapeConfig.type
    and self.shapeTypeTitles[shapeConfig.type]

  if
    Slab.BeginComboBox(
      self.id .. ".type",
      { Selected = selectedShapeTypeTitle }
    )
  then
    for i, shapeType in pairs(self.shapeTypes) do
      local shapeTypeTitle = shapeType and self.shapeTypeTitles[shapeType]
      local selected = selectedShapeTypeTitle == shapeTypeTitle

      if Slab.TextSelectable(shapeTypeTitle, { IsSelected = selected }) then
        shapeConfig.type = shapeType
      end
    end

    Slab.EndComboBox()
  end

  if shapeConfig.type == "circle" then
    Slab.SetLayoutColumn(1)
    Slab.Text("Radius")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.id .. ".radius", {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shapeConfig.radius or 0.5,
      })
    then
      shapeConfig.radius = Slab.GetInputNumber()
    end
  elseif shapeConfig.type == "rectangle" then
    Slab.SetLayoutColumn(1)
    Slab.Text("Width")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.id .. ".width", {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shapeConfig.size and shapeConfig.size[1] or 1,
      })
    then
      shapeConfig.size = shapeConfig.size or { 1, 1 }
      shapeConfig.size[1] = Slab.GetInputNumber()
    end

    Slab.SetLayoutColumn(1)
    Slab.Text("Height")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.id .. ".height", {
        Align = "left",
        NumbersOnly = true,
        ReturnOnText = true,
        Step = self.editorScreen.dragStep,
        Text = shapeConfig.size and shapeConfig.size[2] or 1,
      })
    then
      shapeConfig.size = shapeConfig.size or { 1, 1 }
      shapeConfig.size[2] = Slab.GetInputNumber()
    end
  end

  Slab.EndLayout()
end

return M
