-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local changeHistoryService = game:GetService("ChangeHistoryService")
local listFactory = require(script.Parent.Parent.UI.List)

return function(virtualPlugin)
	local instanceStorage = virtualPlugin.storage
	local layersStorage = instanceStorage:create("Layers")
	
	local layersButton = virtualPlugin.toolbar:addButton("Layers", "The ability to hide groups of items from workspace.", "rbxassetid://1847214094")
	local pluginGui = virtualPlugin.gui:create(script.Name, script.Frame, layersButton)
	local layerLabel = pluginGui.frame.Layers.LayerLabel
	
	layerLabel.Parent = nil
	listFactory:create(pluginGui.frame.Layers)
	
	local layers = {
		list = {},
		
		add = function(layers, layer)
			if(layers.list[layer.folder])then
				return
			end
			
			layers.list[layer.folder] = layer
			layer.label.Parent = pluginGui.frame.Layers
		end,
		
		remove = function(layers, layer)
			if(not layers.list[layer.folder])then
				return
			end
			
			layer.label.Parent = nil
			layers.list[layer.folder].visible = true
			layers.list[layer.folder]:destroy()
			layers.list[layer.folder] = nil
		end
	}
	
	local function setItemVisibilityState(instances, visible, layerFolder)
		if(not layerFolder)then
			return
		end
		
		changeHistoryService:SetWaypoint("SetLayerVisiblilityStart:" .. tostring(layerFolder))
		
		for n, instance in pairs(instances)do
			local originalParent = instance:FindFirstChild("OriginalParent")
			
			if(originalParent and visible)then
				instance.Parent = originalParent.Value
			elseif(not visible)then
				instance.Parent = layerFolder
			end
		end
			
		changeHistoryService:SetWaypoint("SetLayerVisiblilityEnd:" .. tostring(layerFolder))
	end
	
	local function attachLayerItem(layerItem, layerFolder)
		local originalParentValue = layerItem:FindFirstChild("OriginalParent")
		if(not originalParentValue)then
			originalParentValue = Instance.new("ObjectValue")
			originalParentValue.Value = layerItem.Parent
			originalParentValue.Name = "OriginalParent"
		end
		
		return layerItem.AncestryChanged:connect(function()
			if(not layerItem.Parent)then
				return
			end
			
			if(layerItem.Parent == layerFolder)then
				originalParentValue.Parent = layerItem
			else
				originalParentValue.Value = layerItem.Parent
				originalParentValue.Parent = nil
			end
		end)
	end
	
	local function createLayerFolder(layerFolder, visible)
		local events = {}
		
		local layer = setmetatable({
			folder = layerFolder,
			label = layerLabel:Clone(),
			instances = {},
			
			destroy = function(layer)
				layer.visible = true
				
				for n, event in pairs(events)do
					event:disconnect()
				end
			end
		}, {
			__index = function(layer, index)
				if(index == "visible")then
					return #layerFolder:GetChildren() == 0
				end
				
				return rawget(layer, index)
			end,
			
			__newindex = function(layer, index, value)
				if(index == "visible")then
					setItemVisibilityState(layer.instances, not not value, layerFolder)
				end
			end
		})
		
		for n, instance in pairs(layerFolder:GetChildren())do
			table.insert(events, attachLayerItem(instance, layerFolder))
			table.insert(layer.instances, instance)
		end
		
		layerFolder.Changed:connect(function(p)
			if(p == "Name")then
				layer.label.Name = layerFolder.Name
				layer.label.LayerName.Text = layerFolder.Name
			end
		end)
		
		layer.label.ToggleLayer.MouseButton1Click:connect(function()
			layer.visible = not layer.visible
		end)
		
		layer.label.DeleteLayer.MouseButton1Click:connect(function()
			layers:remove(layer)
		end)
		
		layer.label.SelectLayerItems.MouseButton1Click:connect(function()
			game.Selection:Set(layer.instances)
		end)
		
		layer.label.LayerName.FocusLost:connect(function(enterPressed)
			if(enterPressed)then
				layerFolder.Name = layer.label.LayerName.Text
			else
				layer.label.LayerName.Text = layerFolder.Name
			end
		end)
		
		layers:add(layer)
		layer.label.LayerName.Text = layerFolder.Name
		
		return layer
	end
	
	local function createLayer(selection)
		for n, instance in pairs(selection)do
			if(not instance:IsDescendantOf(workspace))then
				return
			end
		end
		
		local layerFolder = instanceStorage:create(selection[1].Name, layersStorage)
		local layer = createLayerFolder(layerFolder, true)
		
		for n, instance in pairs(selection)do
			attachLayerItem(instance, layerFolder)
			table.insert(layer.instances, instance)
		end
	end
	
	pluginGui.frame.Label.AddLayer.MouseButton1Click:connect(function()
		local selection = game.Selection:Get()
		if(#selection > 0)then
			createLayer(selection)
		end
	end)
	
	for n, layerFolder in pairs(layersStorage:GetChildren())do
		if(#layerFolder:GetChildren() > 0)then
			createLayerFolder(layerFolder, false)
			instanceStorage:attachProperties(layerFolder)
		else
			layerFolder.Parent = nil
		end
	end
	
	return {}
end

-- WebGL3D
