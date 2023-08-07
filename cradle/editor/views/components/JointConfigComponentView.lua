local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, component)
  self.editorScreen = assert(editorScreen)
  self.component = assert(component)

  self.jointTypes = { "motor", "revolute", "wheel" }

  self.jointTypeTitles =
    { motor = "Motor", revolute = "Revolute", wheel = "Wheel" }

  self.bodyAId = self.component .. "ComponentBodyA"
  self.bodyBId = self.component .. "ComponentBodyB"
  self.id = self.component .. "Component"
  self.localAnchorAxId = self.component .. "ComponentLocalAnchorAx"
  self.localAnchorAyId = self.component .. "ComponentLocalAnchorAy"
  self.localAnchorBxId = self.component .. "ComponentLocalAnchorBx"
  self.localAnchorById = self.component .. "ComponentLocalAnchorBy"
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

  local jointConfig = self.editorScreen.database:getCell(entity, self.component)

  Slab.BeginLayout(self.id, { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedJointTypeTitle = jointConfig.type
    and self.jointTypeTitles[jointConfig.type]

  if Slab.BeginComboBox(self.typeId, { Selected = selectedJointTypeTitle }) then
    for i, jointType in pairs(self.jointTypes) do
      local jointTypeTitle = assert(self.jointTypeTitles[jointType])
      local selected = selectedJointTypeTitle == jointTypeTitle

      if Slab.TextSelectable(jointTypeTitle, { IsSelected = selected }) then
        jointConfig.type = jointType
      end
    end

    Slab.EndComboBox()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Body A")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.bodyAId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.bodyA or 0,
    })
  then
    jointConfig.bodyA = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor AX")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.localAnchorAxId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.localAnchorA and jointConfig.localAnchorA[1] or 0,
    })
  then
    jointConfig.localAnchorA = jointConfig.localAnchorA or { 0, 0 }
    jointConfig.localAnchorA[1] = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor AY")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.localAnchorAyId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.localAnchorA and jointConfig.localAnchorA[2] or 0,
    })
  then
    jointConfig.localAnchorA = jointConfig.localAnchorA or { 0, 0 }
    jointConfig.localAnchorA[2] = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Body B")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.bodyBId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.bodyB or 0,
    })
  then
    jointConfig.bodyB = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor BX")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.localAnchorBxId, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.localAnchorB and jointConfig.localAnchorB[1] or 0,
    })
  then
    jointConfig.localAnchorB = jointConfig.localAnchorB or { 0, 0 }
    jointConfig.localAnchorB[1] = Slab.GetInputNumber()
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor BY")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.localAnchorById, {
      Align = "left",
      NumbersOnly = true,
      ReturnOnText = true,
      Text = jointConfig.localAnchorB and jointConfig.localAnchorB[2] or 0,
    })
  then
    jointConfig.localAnchorB = jointConfig.localAnchorB or { 0, 0 }
    jointConfig.localAnchorB[2] = Slab.GetInputNumber()
  end

  Slab.EndLayout()
end

return M