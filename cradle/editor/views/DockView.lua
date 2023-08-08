local Class = require("cradle.Class")
local ComponentListView = require("cradle.editor.views.ComponentListView")
local EntityTreeView = require("cradle.editor.views.EntityTreeView")
local SettingsView = require("cradle.editor.views.SettingsView")
local Slab = require("Slab")

local M = Class.new()

function M:init(editorScreen, id, selectedViewType)
  self.editorScreen = assert(editorScreen)
  self.id = assert(id)
  self.selectedViewType = assert(selectedViewType)

  self.viewTypes = { "componentList", "entityTree", "settings" }
  self.viewTypeTitles = {
    componentList = "Component List",
    entityTree = "Entity Tree",
    settings = "Settings",
  }

  self.componentListView =
    ComponentListView.new(self.editorScreen, self.id .. ".componentList")
  self.entityTreeView =
    EntityTreeView.new(self.editorScreen, self.id .. ".entityTree")
  self.settingsView =
    SettingsView.new(self.editorScreen, self.id .. ".settings")
end

function M:render()
  Slab.BeginLayout(self.id .. ".layout", { ExpandW = true })

  local selectedViewTypeTitle = self.viewTypeTitles[self.selectedViewType]

  if
    Slab.BeginComboBox(
      self.id .. ".viewType",
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
  elseif self.selectedViewType == "settings" then
    self.settingsView:render()
  end
end

return M
