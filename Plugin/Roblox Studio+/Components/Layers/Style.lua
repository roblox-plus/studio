-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(controller)
	return {
		["Frame.MainFrame"] = {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0
		},
		["TextLabel.Header"] = {
			Size = UDim2.new(1, 0, 0, 32),
			Text = "Layers",
			TextSize = 24
		},
		["ImageButton.AddLayer"] = {
			Image = "rbxasset://textures/ui/Settings/Slider/More.png",
			Size = UDim2.new(0, 32, 0, 32),
			Position = UDim2.new(1, -32, 0, 0)
		},
		["ScrollingFrame"] = {
			CanvasSize = UDim2.new(1, 0, 0, 24 * controller.layers.count),
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0, 0, 0, 32)
		}
	}, {
		init = function(clearCache, destroyed)
			local events = {}

			table.insert(events, controller.layers.list.valueAdded.Event:connect(clearCache))
			table.insert(events, controller.layers.list.valueRemoved.Event:connect(clearCache))

			return events
		end
	}
end

-- WebGL3D
