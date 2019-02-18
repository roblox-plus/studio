-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local selection = game:GetService("Selection")

return function(parentInstance, args, component)
	-- Visibility sync
	local visible = Instance.new("BoolValue")
	do
		local syncingVisibility = false

		local function syncVisibility(newVisibility)
			syncingVisibility = true
			visible.Value = newVisibility
			syncingVisibility = false
		end

		local function setVisibility(isVisible)
			if (syncingVisibility) then
				return
			end
			args.layer.visible = isVisible
		end

		visible.Value = args.layer.visible
		visible.Changed:connect(setVisibility)
		args.layer.visibilityChanged:connect(syncVisibility)
	end

	return {
		visible = visible,
		folder = args.layer.folder,
		delete = function(event)
			args.layer:destroy()
		end,
		select = function(event)
			selection:Set(args.layer.instances)
		end,
		blur = function(event, enterPressed)
			if (enterPressed) then
				args.layer.folder.Name = event.instance.Text
			else
				event.instance.Text = args.layer.folder.Name
			end
		end
	}
end

-- WebGL3D
