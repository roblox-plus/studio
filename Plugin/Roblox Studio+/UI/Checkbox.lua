-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local checkedTexture = "rbxasset://textures/ui/LuaChat/graphic/ic-checkbox-on.png"
local uncheckedTexture = "rbxasset://textures/ui/LuaChat/graphic/ic-checkbox.png"

return {
	create = function(checkboxFactory, checkboxInstance)
		local changedEvent = Instance.new("BindableEvent")
		
		local checkbox = setmetatable({
			instance = checkboxInstance,
			
			attachSetting = function(checkbox, settingName, pluginInstance)
				checkbox.checked = not not pluginInstance:GetSetting(settingName)
				
				checkbox.changed:connect(function(value)
					pluginInstance:SetSetting(settingName, value)
				end)
			end,
			
			changed = changedEvent.Event
		}, {
			__index = function(checkbox, index)
				if(index == "checked")then
					return checkbox.instance.Image == checkedTexture
				end
			end,
			
			__newindex = function(checkbox, index, value)
				if(index == "checked")then
					value = not not value
					if(checkbox.checked ~= value)then
						checkbox.instance.Image = value and checkedTexture or uncheckedTexture
						changedEvent:Fire(value)
					end
				end
			end
		})
		
		checkbox.instance.MouseButton1Click:connect(function()
			checkbox.checked = not checkbox.checked
		end)
		
		return checkbox
	end
}

-- WebGL3D
