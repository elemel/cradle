local Class = require("cradle.Class")

local M = Class.new()

function M:init(editorScreen, entity, component)
  self.editorScreen = assert(editorScreen)
  self.entity = assert(entity)
  self.component = assert(component)
end

function M:redo()
  local constructor =
    assert(self.editorScreen.componentConstructors[self.component])
  local value = constructor()
  self.editorScreen.database:setCell(self.entity, self.component, value)
end

function M:undo()
  self.editorScreen.database:setCell(self.entity, self.component, nil)
end

return M
