-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local listFactory = require(script.Parent.Parent.UI.List)
local checkboxFactory = require(script.Parent.Parent.UI.Checkbox)

return function(virtualPlugin)
	if(#script.Frame.List:GetChildren() <= 1)then
		return {}
	end
	
	local settingsButton = virtualPlugin.toolbar:addButton("Settings", "Global settings for Roblox Studio+.", "rbxassetid://1847214094")
	local pluginGui = virtualPlugin.gui:create(script.Name, script.Frame, settingsButton)
	local settingsListFrame = pluginGui.frame.List
	
	listFactory:create(settingsListFrame)
	
	return {}
end

-- WebGL3D
