-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local selectionService = game:GetService("Selection")

return function(virtualPlugin)
	local debounce = false
	local selectionHistory = {}
	local historyLimit = 1000
	local historyIndex = nil

	local clearSelectionHistory = virtualPlugin.actions:create("Reset Selection History", "Sets your entire selection history to one point of what is currently selected.", "rbxasset://textures/ui/SelectionBox.png")
	local undoSelectionAction = virtualPlugin.actions:create("Undo Selection Change", "Undoes a change in selection.", "rbxasset://textures/ui/SelectionBox.png")
	local redoSelectionAction = virtualPlugin.actions:create("Redo Selection Change", "Undoes the undo for a change in selection.", "rbxasset://textures/ui/SelectionBox.png")

	local function adjustSelection(delta)
		if (#selectionHistory <= 1) then
			return
		end

		if (delta >= 1) then
			-- Redo (up through the table)
			if (not historyIndex or historyIndex >= #selectionHistory) then
				-- If we've hit the limit and can't go any higher remove the known index and do nothing
				historyIndex = nil
				return
			end
		elseif (delta <= -1) then
			-- Undo (deeper into the table)
			if (not historyIndex) then
				-- If we're just going down start at the top
				historyIndex = #selectionHistory
			end
		else
			return
		end

		historyIndex = math.max(1, math.min(#selectionHistory, historyIndex + delta))
		debounce = true
		selectionService:Set(selectionHistory[historyIndex])
	end

	selectionService.SelectionChanged:connect(function()
		if (debounce) then
			debounce = false
			return
		end

		if (historyIndex) then
			for n = #selectionHistory, math.max(2, historyIndex), -1 do
				table.remove(selectionHistory, n)
			end

			historyIndex = nil
		end

		table.insert(selectionHistory, selectionService:Get())

		while (#selectionHistory > historyLimit) do
			table.remove(selectionHistory, 1)
		end
	end)

	clearSelectionHistory.triggered:connect(function()
		selectionHistory = {
			selectionService:Get()
		}
	end)

	undoSelectionAction.triggered:connect(function()
		adjustSelection(-1)
	end)

	redoSelectionAction.triggered:connect(function()
		adjustSelection(1)
	end)

	clearSelectionHistory:trigger()

	return {}
end

-- WebGL3D
