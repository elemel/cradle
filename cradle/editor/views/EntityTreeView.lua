local Class = require("cradle.Class")
local DeleteEntityCommand =
  require("cradle.editor.commands.DeleteEntityCommand")
local entityMod = require("cradle.entity")
local InsertEntityCommand =
  require("cradle.editor.commands.InsertEntityCommand")
local Slab = require("Slab")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen)
  self.editorScreen = assert(editorScreen)
end

function M:render()
  do
    Slab.BeginLayout("insertAndDeleteEntity", { Columns = 2, ExpandW = true })
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

  for entity in
    self.editorScreen.database.getNextEntity,
    self.editorScreen.database
  do
    local node = self.editorScreen.database:getCell(entity, "node")

    if node and node.parent == 0 then
      self:renderEntityNode(entity)
    end
  end
end

function M:renderEntityNode(entity)
  local label = entityMod.format(self.editorScreen.database, entity)
  local node = self.editorScreen.database:getCell(entity, "node")
  local leaf = node.firstChild == 0
  local selected = self.editorScreen.selectedEntities[entity] or false

  local open = Slab.BeginTree("entity" .. entity, {
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
