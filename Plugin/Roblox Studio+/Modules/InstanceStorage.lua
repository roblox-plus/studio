-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local serverStorage = game:GetService("ServerStorage")
local runService = game:GetService("RunService")

local function getNumberOfArchivableChildren(parent)
	local count = 0
	for n, child in pairs(parent:GetChildren()) do
		if (child.Archivable) then
			count = count + 1
		end
	end
	return count
end

local checkFolder = function(folder)
	folder.Archivable = getNumberOfArchivableChildren(folder) > 0
end

function attachFolderProperties(folder, expectedParent)
	folder.ChildAdded:connect(function()
		checkFolder(folder)
	end)

	folder.ChildRemoved:connect(function()
		checkFolder(folder)
	end)

	folder.Changed:connect(function(p)
		if (p == "Archivable") then
			if (folder.Parent and folder.Parent:IsA("Folder")) then
				checkFolder(folder.Parent)
			end
		end
	end)

	checkFolder(folder)

	folder.Parent = expectedParent
end

function createFolder(name, expectedParent)
	local folder = expectedParent:FindFirstChild(name)

	if (not folder) then
		folder = Instance.new("Folder")
		folder.Name = name
	end

	attachFolderProperties(folder, expectedParent)

	return folder
end

return function(storageName)
	return {
		instance = createFolder(storageName, serverStorage),

		create = function(instanceStorage, name, parent)
			return createFolder(name, parent or instanceStorage.instance)
		end,

		attachProperties = function(instanceStorage, folder, expectedParent)
			attachFolderProperties(folder, expectedParent or folder.Parent)
		end
	}
end

-- WebGL3D
