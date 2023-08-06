local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.bodyTypes = { "dynamic", "kinematic", "static" }
  self.bodyTypeTitles =
    { dynamic = "Dynamic", kinematic = "Kinematic", static = "Static" }

  self.id = self.component .. "Component"
  self.typeId = self.component .. "ComponentType"
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

  local body = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedBodyTypeTitle = body.type and self.bodyTypeTitles[body.type]

  if Slab.BeginComboBox(self.typeId, { Selected = selectedBodyTypeTitle }) then
    for i, bodyType in pairs(self.bodyTypes) do
      local bodyTypeTitle = bodyType and self.bodyTypeTitles[bodyType]
      local selected = selectedBodyTypeTitle == bodyTypeTitle

      if Slab.TextSelectable(bodyTypeTitle, { IsSelected = selected }) then
        body.type = bodyType
      end
    end

    Slab.EndComboBox()
  end

  Slab.EndLayout()
end

return M
