-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(virtualPlugin)
	return {
		create = function(pluginAction, text, description, icon, actionId)
			actionId = actionId or ("RobloxStudioPlus_" .. text:gsub("%W+", ""))

			local triggerEvent = Instance.new("BindableEvent")
			local pluginActionInstance = virtualPlugin.instance:CreatePluginAction(actionId, text, description, icon)

			pluginActionInstance.Triggered:connect(function()
				triggerEvent:Fire(true)
			end)

			return {
				triggered = triggerEvent.Event,

				trigger = function()
					triggerEvent:Fire(false)
				end
			}
		end
	}
end

-- WebGL3D
