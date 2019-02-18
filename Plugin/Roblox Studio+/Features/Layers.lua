-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local changeHistoryService = game:GetService("ChangeHistoryService")
local rangular = require(script.Parent.Parent.Modules.Rangular)

local layersComponent = script.Parent.Parent.Components.Layers

rangular:registerComponent(layersComponent)

return function(virtualPlugin)
	local instanceStorage = virtualPlugin.storage
	local layersStorage = instanceStorage:create("Layers")

	local layersButton =
		virtualPlugin.toolbar:addButton(
		"Layers",
		"The ability to hide groups of items from workspace.",
		"rbxassetid://1847214094"
	)

	local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 256, 256)
	local widget = virtualPlugin.instance:CreateDockWidgetPluginGui("RobloxStudioPlus_Layers", widgetInfo)
	widget.Title = "Layers"

	layersButton.mouseButton1Click:connect(
		function()
			widget.Enabled = not widget.Enabled
		end
	)

	local layers =
		rangular:bootstrap(
		widget,
		layersComponent.Name,
		{
			storage = virtualPlugin.storage
		},
		rangular.instance.StyleService.Themes.Studio
	)

	layers.component:compile()

	return {}
end

-- WebGL3D
