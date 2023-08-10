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
  do
    Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })
    Slab.SetLayoutColumn(1)

    if Slab.Button("Insert") then
      self.editorScreen:doCommand(InsertEntityCommand.new(self.editorScreen))
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
  self:renderEntity()

  for entity in
    self.editorScreen.database.getNextEntity,
    self.editorScreen.database
  do
    self:renderEntity(entity)
  end
end

function M:renderEntity(entity)
  local label = entity and entityMod.format(self.editorScreen.database, entity)
    or ""
  local selected = entity and self.editorScreen.selectedEntities[entity]
    or false

  if
    Slab.Text(label, {
      IsSelectable = true,
      IsSelected = selected,
    })
  then
    tableMod.clear(self.editorScreen.selectedEntities)

    if entity then
      self.editorScreen.selectedEntities[entity] = true
      selected = true
    end
  end
end

return M
