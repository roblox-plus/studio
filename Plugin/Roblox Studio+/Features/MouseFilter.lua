-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
return function(virtualPlugin)
	local mouseFilterAction = virtualPlugin.actions:create("Filter Mouse Items", "Filters items to be hit by the mouse for the Roblox Studio+ plugin.", "rbxassetid://1000000")
	
	mouseFilterAction.triggered:connect(function()
		virtualPlugin.mouse.TargetFilter = game.Selection:Get()[1]
	end)
	
	return {}
end

-- WebGL3D
