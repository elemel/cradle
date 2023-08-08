local Class = require("cradle.Class")
local ComponentListView = require("cradle.editor.views.ComponentListView")
local EntityTreeView = require("cradle.editor.views.EntityTreeView")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, selectedViewType)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.selectedViewType = assert(selectedViewType)

  self.viewTypes = { "componentList", "entityTree" }
  self.viewTypeTitles =
    { componentList = "Component List", entityTree = "Entity Tree" }

  self.componentListView = ComponentListView.new(self.editorScreen)
  self.entityTreeView = EntityTreeView.new(self.editorScreen)

  self.layoutId = self.id .. "Layout"
  self.viewTypeId = self.id .. "ViewType"
end

function M:render()
  Slab.BeginLayout(self.layoutId, { ExpandW = true })

  local selectedViewTypeTitle = self.viewTypeTitles[self.selectedViewType]

  if
    Slab.BeginComboBox(
      self.viewTypeId,
      { ExpandW = true, Selected = selectedViewTypeTitle }
    )
  then
    for i, viewType in pairs(self.viewTypes) do
      local viewTypeTitle = assert(self.viewTypeTitles[viewType])
      local selected = selectedViewTypeTitle == viewTypeTitle

      if Slab.TextSelectable(viewTypeTitle, { IsSelected = selected }) then
        self.selectedViewType = viewType
      end
    end

    Slab.EndComboBox()
  end

  Slab.EndLayout()

  if self.selectedViewType == "componentList" then
    self.componentListView:render()
  elseif self.selectedViewType == "entityTree" then
    self.entityTreeView:render()
  end
end

return M
