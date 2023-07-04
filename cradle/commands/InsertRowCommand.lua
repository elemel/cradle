local Class = require("cradle.Class")
local tableMod = require("cradle.table")

local M = Class.new()

function M:init(editorScreen)
  self.editorScreen = assert(editorScreen)
end

function M:redo()
  self.entity = self.editorScreen.database:insertRow({ node = {} }, self.entity)

  tableMod.clear(self.editorScreen.selectedEntities)
  self.editorScreen.selectedEntities[self.entity] = true
end

function M:undo()
  self.editorScreen.selectedEntities[self.entity] = nil
  self.editorScreen.database:deleteRow(self.entity)
end

return M
