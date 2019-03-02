-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(pluginInstance, isDevelopmentPlugin)
	local virtualPlugin = {
		instance = pluginInstance,
		toolbar = require(script.Toolbar)(pluginInstance, isDevelopmentPlugin),
		mouse = pluginInstance:GetMouse()
	}

	virtualPlugin.storage = require(script.Parent.InstanceStorage)("RobloxPlusStudioStorage_" .. pluginInstance:GetStudioUserId())
	virtualPlugin.actions = require(script.PluginAction)(virtualPlugin)
	virtualPlugin.gui = require(script.PluginGui)(virtualPlugin)

	return virtualPlugin
end

-- WebGL3D
