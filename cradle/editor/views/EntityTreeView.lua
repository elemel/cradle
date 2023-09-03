local Class = require("cradle.Class")
local DeleteEntityCommand =
  require("cradle.editor.commands.DeleteEntityCommand")
local entityMod = require("cradle.entity")
local InsertEntityCommand =
  require("cradle.editor.commands.InsertEntityCommand")
local Slab = require("Slab")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen, id)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
end

function M:render()
  local entity = tableMod.count(self.editorScreen.selectedEntities) == 1
    and next(self.editorScreen.selectedEntities)
  local root = entity

  if root then
    while true do
      local rootNode = self.editorScreen.database:getCell(root, "node")

      if not rootNode or rootNode.parent == 0 then
        break
      end

      root = rootNode.parent
    end
  end

  do
    Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("Entity")

    Slab.SetLayoutColumn(2)

    if
      Slab.Input(self.id .. ".entity", {
        Align = "left",
        Text = entityMod.format(self.editorScreen.database, entity),
      })
    then
      entity = entityMod.parse(Slab.GetInputText())
      tableMod.clear(self.editorScreen.selectedEntities)

      if entity then
        self.editorScreen.selectedEntities[entity] = true
      end
    end

    Slab.SetLayoutColumn(1)

    if Slab.Button("Insert") then
      local parentEntity = tableMod.count(self.editorScreen.selectedEntities)
          == 1
        and next(self.editorScreen.selectedEntities)

      self.editorScreen:doCommand(
        InsertEntityCommand.new(self.editorScreen, parentEntity)
      )
    end

    Slab.SetLayoutColumn(2)
    local deleteDisabled = tableMod.count(self.editorScreen.selectedEntities)
      ~= 1

    if Slab.Button("Delete", { Disabled = deleteDisabled }) then
      local entity = next(self.editorScreen.selectedEntities)
      self.editorScreen:doCommand(
        DeleteEntityCommand.new(self.editorScreen, entity)
      )
    end

    Slab.EndLayout()
  end

  Slab.Separator()

  if root then
    self:renderEntityNode(root)
  end
end

function M:renderEntityNode(entity)
  local label = entityMod.format(self.editorScreen.database, entity)
  local node = self.editorScreen.database:getCell(entity, "node")
  local leaf = not node or node.firstChild == 0
  local selected = self.editorScreen.selectedEntities[entity] or false

  local open = Slab.BeginTree(self.id .. ".entity" .. entity, {
    IsLeaf = leaf,
    IsSelected = selected,
    Label = label,
    OpenWithHighlight = false,
  })

  if Slab.IsControlClicked() then
    tableMod.clear(self.editorScreen.selectedEntities)
    self.editorScreen.selectedEntities[entity] = true
    selected = true
  end

  if open then
    if not leaf then
      local childEntity = node.firstChild

      repeat
        self:renderEntityNode(childEntity)

        local childNode =
          self.editorScreen.database:getCell(childEntity, "node")
        childEntity = childNode.nextSibling
      until childEntity == node.firstChild
    end

    Slab.EndTree()
  end
end

return M
