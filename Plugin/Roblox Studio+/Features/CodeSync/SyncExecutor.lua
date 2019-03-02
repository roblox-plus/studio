-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local changeHistoryService = game:GetService("ChangeHistoryService")
local syncService = require(script.Parent.SyncService)

return (function(storageFolder)
	local mappingsUpdated = Instance.new("BindableEvent")

	local function import(parentInstance, importData)
		local instanceMap = {}

		for i, instanceData in pairs(importData) do
			local instance = parentInstance:FindFirstChild(instanceData.name)
			if (not instance or instance.ClassName ~= instanceData.className) then
				instance = Instance.new(instanceData.className, parentInstance)
				instance.Name = instanceData.name
			end

			for propertyName, propertyValue in pairs(instanceData.properties) do
				instance[propertyName] = propertyValue
			end

			import(instance, instanceData.children)
			instanceMap[instance] = true
		end

		for n, instance in pairs(parentInstance:GetChildren()) do
			if (not instanceMap[instance] and (instance:IsA("LuaSourceContainer") or instance:IsA("Folder"))) then
				instance:Destroy()
			end
		end
	end

	local function isMapping(mappingInstance)
		if (not mappingInstance:IsA("ObjectValue") or mappingInstance.Name ~= "SyncMapping") then
			return false
		end

		local mappedDirectory = mappingInstance:FindFirstChild("MappedDirectory")
		local lastUpdated = mappingInstance:FindFirstChild("Updated")

		if (mappedDirectory and mappedDirectory:IsA("StringValue") and mappedDirectory.Value ~= "" and mappingInstance.Value and mappingInstance.Value.Parent and lastUpdated and lastUpdated:IsA("NumberValue")) then
			return true
		end

		return false
	end

	local getMappedObjects = function()
		local mappedObjects = {}

		for n, mappingInstance in pairs(storageFolder:GetChildren()) do
			if (mappingInstance:IsA("ObjectValue") and mappingInstance.Name == "SyncMapping") then
				if (isMapping(mappingInstance)) then
					table.insert(mappedObjects, mappingInstance)
				else
					mappingInstance:Destroy()
				end
			end
		end

		return mappedObjects
	end

	local setSyncDirectory = function(syncExecutor, instance, directory)
		local mapping = syncExecutor:getMapping(instance)

		if (mapping) then
			mapping.MappedDirectory.Value = directory
		else
			mapping = Instance.new("ObjectValue")
			mapping.Name = "SyncMapping"
			mapping.Value = instance

			local mappedDirectory = Instance.new("StringValue", mapping)
			mappedDirectory.Name = "MappedDirectory"
			mappedDirectory.Value = directory

			local lastUpdated = Instance.new("NumberValue", mapping)
			lastUpdated.Name = "Updated"

			mapping.Parent = storageFolder
		end

		return mapping
	end

	local function onMappingsUpdated()
		mappingsUpdated:Fire()
	end

	storageFolder.ChildAdded:connect(function(mappingInstance)
		if (isMapping(mappingInstance)) then
			mappingInstance.Changed:connect(onMappingsUpdated)
		end

		onMappingsUpdated()
	end)

	storageFolder.ChildRemoved:connect(onMappingsUpdated)

	return {
		mappingsUpdated = mappingsUpdated.Event,

		import = function(syncExecutor, parentInstance, directory)
			local importData = syncService:import(directory)
			import(parentInstance, importData)
			setSyncDirectory(syncExecutor, parentInstance, directory)
		end,

		export = function(syncExecutor, instance, location)
			local mapping = syncExecutor:getMapping(instance)
			local exportData = syncExecutor:createExportData(instance)

			if (mapping) then
				if (mapping.Value ~= instance) then
					error("Export requires full parent to be selected.")
				end
			else
				mapping = setSyncDirectory(syncExecutor, instance, location)
			end

			if (syncService:export(exportData, location)) then
				mapping.MappedDirectory.Value = location
				mapping.Updated.Value = os.time()
			end
		end,

		getMappings = function()
			local map = {}

			for n, mappingInstance in pairs(getMappedObjects()) do
				map[mappingInstance.Value] = mappingInstance.MappedDirectory
			end

			return map
		end,

		getMapping = function(syncExecutor, instance)
			for n, mappingInstance in pairs(getMappedObjects()) do
				if (instance == mappingInstance.Value or instance:IsDescendantOf(mappingInstance.Value)) then
					return mappingInstance
				end
			end

			return nil
		end,

		createExportData = function(syncExecutor, parentInstance)
			local data = {}

			for i, instance in pairs(parentInstance:GetChildren()) do
				local instanceData = {
					name = instance.Name,
					className = instance.ClassName,
					properties = {
						Name = instance.Name,
						ClassName = instance.ClassName
					},
					children = syncExecutor:createExportData(instance)
				}

				if (instance:IsA("LuaSourceContainer")) then
					instanceData.properties.Source = instance.Source
				end

				table.insert(data, instanceData)
			end

			return data
		end
	}
end)

-- WebGL3D
