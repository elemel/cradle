local Class = require("cradle.Class")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
end

function M:render()
  do
    Slab.BeginLayout(self.id .. ".layout", { Columns = 2, ExpandW = true })

    Slab.SetLayoutColumn(1)
    Slab.Text("Drag Step")

    Slab.SetLayoutColumn(2)
    local selectedDragStepTitle = tostring(self.editorScreen.dragStep)

    if
      Slab.BeginComboBox(
        self.id .. ".dragStep",
        { Selected = selectedDragStepTitle }
      )
    then
      for _, dragStepTitle in ipairs({
        "0.001",
        "0.01",
        "0.1",
        "1",
        "10",
        "100",
        "1000",
      }) do
        local selected = selectedDragStepTitle == dragStepTitle

        if Slab.TextSelectable(dragStepTitle, { IsSelected = selected }) then
          self.editorScreen.dragStep = tonumber(dragStepTitle)
        end
      end

      Slab.EndComboBox()
    end

    Slab.EndLayout()
  end
end

return M
