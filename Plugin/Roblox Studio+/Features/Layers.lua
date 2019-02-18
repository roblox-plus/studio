-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local changeHistoryService = game:GetService("ChangeHistoryService")
local rangular = require(script.Parent.Parent.Modules.Rangular)

local layersComponent = script.Parent.Parent.Components.Layers

rangular:registerComponent(layersComponent)

return function(virtualPlugin)
	local layers =
		rangular:bootstrap(
		nil,
		layersComponent.Name,
		{
			storage = virtualPlugin.storage,
			pluginInstance = virtualPlugin.instance,
			toolbar = virtualPlugin.toolbar
		},
		rangular.instance.StyleService.Themes.Studio
	)

	layers.component:compile()

	return {}
end

-- WebGL3D
