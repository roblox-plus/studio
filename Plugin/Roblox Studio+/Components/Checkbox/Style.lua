-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local checkedTexture = "rbxasset://textures/ui/LuaChat/graphic/ic-checkbox-on.png"
local uncheckedTexture = "rbxasset://textures/ui/LuaChat/graphic/ic-checkbox.png"

return function(controller)
	return {
		["ImageButton"] = {
			Image = controller.checked.Value and checkedTexture or uncheckedTexture
		}
	}, {
		init = function(clearCache, destroyed)
			local events = {}

			table.insert(events, controller.checked.Changed:connect(clearCache))
			
			return events
		end
	}
end

-- WebGL3D