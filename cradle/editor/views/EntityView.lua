local AddComponentCommand =
  require("cradle.editor.commands.AddComponentCommand")
local Class = require("cradle.Class")
local RemoveComponentCommand =
  require("cradle.editor.commands.RemoveComponentCommand")
local Slab = require("Slab")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen)
  self.editorScreen = assert(editorScreen)
end

function M:render()
  local entity = tableMod.count(self.editorScreen.selectedEntities) == 1
    and next(self.editorScreen.selectedEntities)

  if not entity then
    return
  end

  do
    Slab.BeginLayout("addAndRemoveComponent", { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("Entity")

    Slab.SetLayoutColumn(2)
    Slab.Text(entity)

    Slab.SetLayoutColumn(1)
    Slab.Text("Component")

    Slab.SetLayoutColumn(2)
    local selectedLabel = self.editorScreen.selectedComponent
        and self.editorScreen.componentTitles[self.editorScreen.selectedComponent]
      or self.editorScreen.selectedComponent

    if Slab.BeginComboBox("component", { Selected = selectedLabel }) then
      for i, component in pairs(self.editorScreen.sortedComponents) do
        local label = self.editorScreen.componentTitles[component] or component
        local selected = label == selectedLabel

        if Slab.TextSelectable(label, { IsSelected = selected }) then
          self.editorScreen.selectedComponent = component
        end
      end

      Slab.EndComboBox()
    end

    Slab.SetLayoutColumn(1)

    local addDisabled = not self.editorScreen.selectedComponent
      or self.editorScreen.database:getCell(
          entity,
          self.editorScreen.selectedComponent
        )
        ~= nil

    if Slab.Button("Add", { Disabled = addDisabled }) then
      self.editorScreen:doCommand(
        AddComponentCommand.new(
          self.editorScreen,
          entity,
          self.editorScreen.selectedComponent
        )
      )
    end

    Slab.SetLayoutColumn(2)

    local removeDisabled = not self.editorScreen.selectedComponent
      or self.editorScreen.database:getCell(
          entity,
          self.editorScreen.selectedComponent
        )
        == nil

    if Slab.Button("Remove", { Disabled = removeDisabled }) then
      self.editorScreen:doCommand(
        RemoveComponentCommand.new(
          self.editorScreen,
          entity,
          self.editorScreen.selectedComponent
        )
      )
    end

    Slab.SetLayoutColumn(1)
    Slab.Text("Drag Step")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input("dragStep", {
        Align = "left",
        MaxNumber = 2,
        MinNumber = 0,
        NumbersOnly = true,
        ReturnOnText = true,
        Text = self.editorScreen.dragStep,
        UseSlider = true,
      })
    then
      self.editorScreen.dragStep = Slab.GetInputNumber()
    end

    Slab.EndLayout()
  end

  local archetype = self.editorScreen.database:getArchetype(entity)
  local sortedComponents = tableMod.keys(archetype)

  table.sort(sortedComponents, function(a, b)
    return self.editorScreen.componentTitles[a]
      < self.editorScreen.componentTitles[b]
  end)

  for _, component in ipairs(sortedComponents) do
    Slab.Separator()
    local view = assert(self.editorScreen.componentViews[component])
    view:render()
  end
end

return M
