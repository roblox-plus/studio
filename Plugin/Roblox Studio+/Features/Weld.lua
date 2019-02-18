-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local changeHistoryService = game:GetService("ChangeHistoryService")
local selectionService = game:GetService("Selection")

local function getWeldableSelection(selection)
	local weldParts = {}
	
	for n, part in pairs(selection)do
		if(part:IsA("BasePart"))then
			table.insert(weldParts, part)
		end
	end
	
	return weldParts
end

return function(virtualPlugin)	
	local weldAction = virtualPlugin.actions:create("Weld Selection", "Welds selection to first selected part.", "rbxassetid://161183585")
	
	weldAction.triggered:connect(function()
		local selection = selectionService:Get()
		local weldParts = getWeldableSelection(selection)
		local primaryPart = weldParts[1]
		
		if(#weldParts < 2)then
			warn("At least two parts must be selected to weld.")
			return
		end
		
		if(#weldParts ~= #selection)then
			error("Selection must be only parts to weld.")
			return
		end
		
		changeHistoryService:SetWaypoint("WeldStart:" .. tostring(primaryPart))
		
		for n = 2, #weldParts do
			local part = weldParts[n]
			local weld = Instance.new("Weld")
			
			weld.Part0, weld.Part1 = primaryPart, part
			weld.C0 = primaryPart.CFrame:toObjectSpace(part.CFrame)
			
			weld.Parent = primaryPart
		end
		
		changeHistoryService:SetWaypoint("WeldEnd:" .. tostring(primaryPart))
	end)
	
	return {}
end

-- WebGL3D
