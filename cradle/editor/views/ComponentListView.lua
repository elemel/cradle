local AddComponentCommand =
  require("cradle.editor.commands.AddComponentCommand")
local BodyConfigComponentView =
  require("cradle.editor.views.components.BodyConfigComponentView")
local Class = require("cradle.Class")
local ColorComponentView =
  require("cradle.editor.views.components.ColorComponentView")
local entityMod = require("cradle.entity")
local FixtureConfigComponentView =
  require("cradle.editor.views.components.FixtureConfigComponentView")
local JointConfigComponentView =
  require("cradle.editor.views.components.JointConfigComponentView")
local RemoveComponentCommand =
  require("cradle.editor.commands.RemoveComponentCommand")
local ShapeConfigComponentView =
  require("cradle.editor.views.components.ShapeConfigComponentView")
local Slab = require("Slab")
local StringComponentView =
  require("cradle.editor.views.components.StringComponentView")
local tableMod = require("cradle.table")
local TagComponentView =
  require("cradle.editor.views.components.TagComponentView")
local TransformComponentView =
  require("cradle.editor.views.components.TransformComponentView")

local M = Class.new()

function M:init(editorScreen, id)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)

  self.componentViews = {
    camera = TagComponentView.new(
      self.editorScreen,
      self.id .. ".components.camera",
      "camera"
    ),
    bodyConfig = BodyConfigComponentView.new(self.editorScreen, "bodyConfig"),
    debugColor = ColorComponentView.new(self.editorScreen, "debugColor"),
    fixtureConfig = FixtureConfigComponentView.new(
      self.editorScreen,
      "fixtureConfig"
    ),
    jointConfig = JointConfigComponentView.new(
      self.editorScreen,
      "jointConfig"
    ),
    node = TagComponentView.new(
      self.editorScreen,
      self.id .. ".components.node",
      "node"
    ),
    shapeConfig = ShapeConfigComponentView.new(
      self.editorScreen,
      "shapeConfig"
    ),
    title = StringComponentView.new(self.editorScreen, "title"),
    transform = TransformComponentView.new(self.editorScreen, "transform"),
  }

  self.componentId = self.id .. ".component"
  self.dragStepId = self.id .. ".dragStep"
  self.layoutId = self.id .. ".layout"
end

function M:render()
  local entity = tableMod.count(self.editorScreen.selectedEntities) == 1
    and next(self.editorScreen.selectedEntities)

  if not entity then
    return
  end

  do
    Slab.BeginLayout(self.layoutId, { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("Entity")

    Slab.SetLayoutColumn(2)
    Slab.Text(entityMod.format(self.editorScreen.database, entity))

    Slab.SetLayoutColumn(1)
    Slab.Text("Component")

    Slab.SetLayoutColumn(2)
    local selectedLabel = self.editorScreen.selectedComponent
        and self.editorScreen.componentTitles[self.editorScreen.selectedComponent]
      or self.editorScreen.selectedComponent

    if Slab.BeginComboBox(self.componentId, { Selected = selectedLabel }) then
      local selected = not self.editorScreen.selectedComponent

      if Slab.TextSelectable("", { IsSelected = selected }) then
        self.editorScreen.selectedComponent = nil
      end

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
    local selectedDragStepTitle = tostring(self.editorScreen.dragStep)

    if
      Slab.BeginComboBox(self.dragStepId, { Selected = selectedDragStepTitle })
    then
      for _, dragStepTitle in ipairs({
        "0.001",
        "0.01",
        "0.1",
        "1",
        "10",
        "100",
        "1000",
      }) do
        local selected = selectedDragStepTitle == dragStepTitle

        if Slab.TextSelectable(dragStepTitle, { IsSelected = selected }) then
          self.editorScreen.dragStep = tonumber(dragStepTitle)
        end
      end

      Slab.EndComboBox()
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
    local view = assert(self.componentViews[component])
    view:render()
  end
end

return M
