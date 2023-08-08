local Class = require("cradle.Class")
local entityMod = require("cradle.entity")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, component)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.component = assert(component)

  self.jointTypes = { "motor", "revolute", "wheel" }

  self.jointTypeTitles =
    { motor = "Motor", revolute = "Revolute", wheel = "Wheel" }
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

  Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

  Slab.SetLayoutColumn(1)
  Slab.Text("Type")

  Slab.SetLayoutColumn(2)

  local selectedJointTypeTitle = jointConfig.type
    and self.jointTypeTitles[jointConfig.type]

  if
    Slab.BeginComboBox(
      self.id .. ".type",
      { Selected = selectedJointTypeTitle }
    )
  then
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
    Slab.Input(self.id .. ".bodyA", {
      Align = "left",
      ReturnOnText = true,
      Text = entityMod.format(
        self.editorScreen.database,
        jointConfig.bodyA or 0
      ),
    })
  then
    jointConfig.bodyA = entityMod.parse(Slab.GetInputText())
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor AX")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".localAnchorAx", {
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
    Slab.Input(self.id .. ".localAnchorAy", {
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
    Slab.Input(self.id .. "bodyB", {
      Align = "left",
      ReturnOnText = true,
      Text = entityMod.format(
        self.editorScreen.database,
        jointConfig.bodyB or 0
      ),
    })
  then
    jointConfig.bodyB = entityMod.parse(Slab.GetInputText())
  end

  Slab.SetLayoutColumn(1)
  Slab.Text("Local Anchor BX")

  Slab.SetLayoutColumn(2)

  if
    Slab.Input(self.id .. ".localAnchorBx", {
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
    Slab.Input(self.id .. ".localAnchorBy", {
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
