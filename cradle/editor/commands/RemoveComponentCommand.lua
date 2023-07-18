local Class = require("cradle.Class")

local M = Class.new()

function M:init(editorScreen, entity, component)
  self.editorScreen = assert(editorScreen)
  self.entity = assert(entity)
  self.component = assert(component)
end

function M:redo()
  self.value = self.editorScreen.database:getCell(self.entity, self.component)
  self.editorScreen.database:setCell(self.entity, self.component, nil)
end

function M:undo()
  self.editorScreen.database:setCell(self.entity, self.component, self.value)
end

return M
