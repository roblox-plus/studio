-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local emojiList = require(script.Parent.Parent.Parent.Modules.EmojiList)

return function(controller)
	local selection = controller.selection:Get()

	return {
		["Frame.MainFrame"] = {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0
		},

		["TextLabel.Header"] = {
			Size = UDim2.new(1, 0, 0, 32),
			Text = "  Code Sync",
			TextXAlignment = Enum.TextXAlignment.Left
		},

		["TextLabel.Import,TextLabel.Export"] = {
			Size = UDim2.new(0, 32, 0, 32)
		},

		["TextLabel.Import"] = {
			Visible = controller:canImport(),
			Position = UDim2.new(1, -64, 0, 0),
			Text = emojiList[":open_file_folder:"]
		},

		["TextLabel.Export"] = {
			Visible = controller:canExport(),
			Position = UDim2.new(1, -32, 0, 0),
			Text = emojiList[":floppy_disk:"]
		},

		["ScrollingFrame"] = {
			Size = UDim2.new(1, 0, 1, -32),
			Position = UDim2.new(0, 0, 0, 32)
		}
	}, {
		init = function(clearCache, destroyed)
			local events = {}

			table.insert(events, controller.selection.SelectionChanged:connect(clearCache))
			table.insert(events, controller.mappingsUpdated:connect(clearCache))

			return events
		end
	}
end

-- WebGL3D
