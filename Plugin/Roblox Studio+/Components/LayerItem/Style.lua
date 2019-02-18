-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(controller)
	return {
		["Frame"] = {
			Size = UDim2.new(1, 0, 0, 24),
			Name = controller.folder.Name
		},

		["ImageButton.Checkbox"] = {
			Size = UDim2.new(0, 24, 0, 24)
		},

		["ImageButton.DeleteLayer"] = {
			Image = "rbxasset://textures/ui/Keyboard/close_button_icon.png",
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 24, 0 ,0)
		},

		["ImageButton.SelectLayerItems"] = {
			Image = "rbxasset://textures/ui/SelectionBox.png",
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 48, 0, 0)
		},

		["TextBox"] = {
			Size = UDim2.new(1, -75, 1, 0),
			Position = UDim2.new(0, 75, 0, 0),
			Text = controller.folder.Name,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left
		}
	}, {
		init = function(clearCache, destroyed)
			local events = {}

			table.insert(events, controller.folder:GetPropertyChangedSignal("Name"):connect(clearCache))
			
			return events
		end
	}
end

-- WebGL3D