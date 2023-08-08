local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, component)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.component = assert(component)

  self.bodyTypes = { "dynamic", "kinematic", "static" }
  self.bodyTypeTitles =
    { dynamic = "Dynamic", kinematic = "Kinematic", static = "Static" }
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

  local bodyConfig = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedBodyTypeTitle = bodyConfig.type
    and self.bodyTypeTitles[bodyConfig.type]

  if
    Slab.BeginComboBox(self.id .. ".type", { Selected = selectedBodyTypeTitle })
  then
    for i, bodyType in pairs(self.bodyTypes) do
      local bodyTypeTitle = bodyType and self.bodyTypeTitles[bodyType]
      local selected = selectedBodyTypeTitle == bodyTypeTitle

      if Slab.TextSelectable(bodyTypeTitle, { IsSelected = selected }) then
        bodyConfig.type = bodyType
      end
    end

    Slab.EndComboBox()
  end

  Slab.EndLayout()
end

return M
