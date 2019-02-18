-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return function(virtualPlugin)
	return {
		create = function(pluginGuiFactory, name, frame, toolbarButton)
			local pluginGuiId = "RobloxStudioPlus_" .. name:gsub("%W+", "")
			local visibilityChangedEvent = Instance.new("BindableEvent")
			
			local pluginGui = setmetatable({
				instance = virtualPlugin.instance:CreateDockWidgetPluginGui(pluginGuiId, DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Float,
					false, -- Enabled
					false, -- Don't override the saved enabled/dock state
					frame.Size.X.Offset,
					frame.Size.Y.Offset,
					frame.Size.X.Offset,
					frame.Size.Y.Offset
				)),
				
				frame = frame:Clone(),
				
				visibilityChanged = visibilityChangedEvent.Event
			}, {
				__index = function(pluginGui, index)
					if(index == "visible")then
						return pluginGui.instance.Enabled
					end
				end,
				
				__newindex = function(pluginGui, index, val)
					if(index == "visible")then
						pluginGui.instance.Enabled = not not val
					end
				end
			})
			
			pluginGui.instance.Title = name
			
			if(pluginGui.frame)then
				pluginGui.frame.Name = name
				pluginGui.frame.Parent = pluginGui.instance
				pluginGui.frame.Size = UDim2.new(1, 0, 1, 0)
				pluginGui.frame.Position = UDim2.new(0, 0, 0 ,0)
			end
			
			pluginGui.instance.Changed:connect(function(property)
				if(property == "Enabled")then
					visibilityChangedEvent:Fire(pluginGui.visible)
				end
			end)
			
			if(toolbarButton)then
				local function buttonActivationCheck(visible)
					toolbarButton.active = visible
				end
			
				toolbarButton.mouseButton1Click:connect(function()
					pluginGui.visible = not pluginGui.visible
				end)
				
				buttonActivationCheck(pluginGui.visible)
				pluginGui.visibilityChanged:connect(buttonActivationCheck)
			end
			
			return pluginGui
		end
	}
end

-- WebGL3D
