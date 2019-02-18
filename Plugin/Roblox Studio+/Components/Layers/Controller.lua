-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local selection = game:GetService("Selection")
local changeHistoryService = game:GetService("ChangeHistoryService")
local dynamicListMetatable = require(script.Parent.Parent.Parent.Modules.Rangular.Modules.DynamicListMetatable)

return function(parentInstance, args, component)
	local layersStorage = args.storage:create("Layers")

	local layers = {
		count = 0,
		list = setmetatable({}, dynamicListMetatable),
		add = function(layers, layer)
			if (layers.list[layer.folder]) then
				return
			end

			layers.count = layers.count + 1
			layers.list:add(layer, layer.folder)
		end,
		remove = function(layers, layer)
			if (not layers.list[layer.folder]) then
				return
			end

			layers.count = layers.count - 1
			layers.list[layer.folder]:disconnect()
			layers.list:remove(layer.folder, true)
		end
	}

	local function setItemVisibilityState(instances, visible, layerFolder)
		if (not layerFolder) then
			return
		end

		changeHistoryService:SetWaypoint("SetLayerVisiblilityStart:" .. tostring(layerFolder))

		for n, instance in pairs(instances) do
			local originalParent = instance:FindFirstChild("OriginalParent")

			if (originalParent and visible) then
				instance.Parent = originalParent.Value
			elseif (not visible) then
				instance.Parent = layerFolder
			end
		end

		changeHistoryService:SetWaypoint("SetLayerVisiblilityEnd:" .. tostring(layerFolder))
	end

	local function attachLayerItem(layerItem, layerFolder)
		local originalParentValue = layerItem:FindFirstChild("OriginalParent")
		if (not originalParentValue) then
			originalParentValue = Instance.new("ObjectValue")
			originalParentValue.Value = layerItem.Parent == layerFolder and workspace or layerItem.Parent
			originalParentValue.Name = "OriginalParent"

			-- If we can't find the original parent and we're somehow already in the folder
			-- it will go into workspace.
			if (layerItem.Parent == layerFolder) then
				originalParentValue.Value = workspace
			else
				originalParentValue.Value = layerItem.Parent
			end
		end

		local checkAncestry = function()
			if (not layerItem.Parent) then
				return
			end

			if (layerItem.Parent == layerFolder) then
				originalParentValue.Parent = layerItem
			else
				originalParentValue.Value = layerItem.Parent
				originalParentValue.Parent = nil
			end
		end

		checkAncestry()

		return layerItem.AncestryChanged:connect(checkAncestry)
	end

	local function createLayerFolder(layerFolder)
		local events = {}
		local visibility = Instance.new("BoolValue")

		local layer =
			setmetatable(
			{
				folder = layerFolder,
				visibilityChanged = visibility.Changed,
				instances = {},
				disconnect = function(layer)
					layer.visible = true

					for n, event in pairs(events) do
						event:disconnect()
					end
				end,
				destroy = function(layer)
					layers:remove(layer)
				end
			},
			{
				__index = function(layer, index)
					if (index == "visible") then
						return #layerFolder:GetChildren() == 0
					end

					return rawget(layer, index)
				end,
				__newindex = function(layer, index, value)
					if (index == "visible") then
						setItemVisibilityState(layer.instances, not (not value), layerFolder)
					end
				end
			}
		)

		for n, instance in pairs(layerFolder:GetChildren()) do
			for i, child in pairs(instance:GetChildren()) do
				if (child:IsA("ObjectValue") and child.Name == "OriginalParent" and not child.Value) then
					child:Destroy()
				end
			end

			table.insert(events, attachLayerItem(instance, layerFolder))
			table.insert(layer.instances, instance)
		end

		layers:add(layer)

		do -- Visibility Sync
			local checkVisibility = function()
				visibility.Value = layer.visible
			end

			table.insert(events, layerFolder.ChildAdded:connect(checkVisibility))
			table.insert(events, layerFolder.ChildRemoved:connect(checkVisibility))
			table.insert(events, changeHistoryService.OnUndo:connect(checkVisibility))
			table.insert(events, changeHistoryService.OnRedo:connect(checkVisibility))
			checkVisibility()
		end

		return layer
	end

	local function createLayer(selection)
		if (#selection <= 0) then
			return
		end

		for n, instance in pairs(selection) do
			if (not instance:IsDescendantOf(workspace)) then
				return
			end
		end

		local layerFolder = args.storage:create(selection[1].Name, layersStorage)
		local layer = createLayerFolder(layerFolder)

		for n, instance in pairs(selection) do
			attachLayerItem(instance, layerFolder)
			table.insert(layer.instances, instance)
		end
	end

	for n, layerFolder in pairs(layersStorage:GetChildren()) do
		if (#layerFolder:GetChildren() > 0) then
			createLayerFolder(layerFolder)
			args.storage:attachProperties(layerFolder)
		else
			layerFolder.Parent = nil
		end
	end

	return {
		layers = layers,
		addLayerClick = function(event)
			createLayer(selection:Get())
		end
	}
end

-- WebGL3D
