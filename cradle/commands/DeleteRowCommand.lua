local Class = require("cradle.Class")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen, entity)
  self.editorScreen = assert(editorScreen)
  self.entity = assert(entity)
end

function M:redo()
  self.editorScreen.selectedEntities[self.entity] = nil

  self.row = self.editorScreen.database:getRow(self.entity)
  self.editorScreen.database:deleteRow(self.entity)
end

function M:undo()
  self.editorScreen.database:insertRow(self.row, self.entity)

  tableMod.clear(self.editorScreen.selectedEntities)
  self.editorScreen.selectedEntities[self.entity] = true
end

return M
