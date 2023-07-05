local Class = require("cradle.Class")
local nodeMod = require("cradle.node")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen, parentEntity)
  self.editorScreen = assert(editorScreen)
  self.parentEntity = parentEntity
end

function M:redo()
  self.entity = self.editorScreen.database:insertRow({ node = {} }, self.entity)
  nodeMod.setParent(self.editorScreen.database, self.entity, self.parentEntity)

  tableMod.clear(self.editorScreen.selectedEntities)
  self.editorScreen.selectedEntities[self.entity] = true
end

function M:undo()
  self.editorScreen.selectedEntities[self.entity] = nil

  nodeMod.setParent(self.editorScreen.database, self.entity, nil)
  self.editorScreen.database:deleteRow(self.entity)
end

return M
