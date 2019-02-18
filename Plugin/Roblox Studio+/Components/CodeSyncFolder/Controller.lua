-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local selection = game:GetService("Selection")

return function(parentInstance, args, component)
	local isSelected = Instance.new("BoolValue")
	
	local setSelected = function()
		local selected = false
		
		for n, selectedInstance in pairs(selection:Get()) do
			if (args.instance == selectedInstance or selectedInstance:IsDescendantOf(args.instance)) then
				selected = true
				break
			end
		end
		
		isSelected.Value = selected
	end
	
	selection.SelectionChanged:connect(setSelected)
	setSelected()
	
	return {
		isSelected = isSelected,
		
		selectInstance = function(event)
			selection:Set({ args.instance })
		end,
		
		configureFolder = function(event)
			local newLocation = args.syncService:selectFolderPath()
			if (newLocation) then
				args.syncExecutor:export(args.instance, newLocation)
			end
		end,
		
		openFolder = function(event)
			args.syncService:openFileExplorer(args.folderPath.Value)
		end,
		
		sync = function(event)
			warn("Right now sync only imports")
			args.syncExecutor:import(args.instance, args.folderPath.Value)
		end
	}
end

-- WebGL3D
