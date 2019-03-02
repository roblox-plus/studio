-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local selection = game:GetService("Selection")
local emojiList = require(script.Parent.Parent.Parent.Modules.EmojiList)
local height = 24
local buttonCount = 3

return function(controller)
	local textTransparency = controller.isSelected.Value and 0 or 0.5

	return {
		["Frame.SyncFolder"] = {
			Size = UDim2.new(1, 0, 0, height)
		},

		["TextLabel.OpenSyncFolder"] = {
			Text = emojiList[":open_file_folder:"],
			TextScaled = true,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, height, 0, height),
			TextTransparency = textTransparency
		},

		["TextLabel.ConfigureSyncFolder"] = {
			Text = emojiList[":wrench:"],
			TextScaled = true,
			Position = UDim2.new(0, height, 0, 0),
			Size = UDim2.new(0, height, 0, height),
			TextTransparency = textTransparency
		},

		["TextLabel.Sync"] = {
			Text = emojiList[":arrows_ccw:"],
			TextScaled = true,
			Position = UDim2.new(0, height * 2, 0, 0),
			Size = UDim2.new(0, height, 0, height),
			TextTransparency = textTransparency
		},

		["TextLabel.Folder"] = {
			Size = UDim2.new(1, -(height * buttonCount), 0, height),
			Position = UDim2.new(0, height * buttonCount, 0, 0),
			Text = " " .. controller.folderPath.Value,
			TextXAlignment = Enum.TextXAlignment.Left
		}
	}, {
		init = function(clearCache, destroyed)
			local events = {}

			table.insert(events, controller.isSelected.Changed:connect(clearCache))
			table.insert(events, controller.folderPath.Changed:connect(clearCache))

			return events
		end
	}
end

-- WebGL3D
