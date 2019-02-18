-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(pluginInstance, isDevelopmentPlugin)
	return {
		instance = pluginInstance:CreateToolbar("Roblox Studio+" .. (isDevelopmentPlugin and " [Dev]" or "")),
		
		addButton = function(toolbar, name, tooltip, texture)
			local active = false
			
			local button = setmetatable({
				instance = toolbar.instance:CreateButton(name, tooltip, texture)
			}, {
				__index = function(button, ind)
					if(ind == "mouseButton1Click")then
						return button.instance.Click
					elseif(ind == "active")then
						return active
					end
					
					return rawget(button, ind)
				end,
					
				__newindex = function(button, ind, val)
					if(ind == "active")then
						active = not not val
						button.instance:SetActive(active)
					end
				end
			})
			
			button.mouseButton1Click:connect(function()
				button.instance:SetActive(active)
			end)
			
			return button
		end
	}
end

-- WebGL3D
