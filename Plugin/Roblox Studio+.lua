-- CodeSync: Script (2/18/2019 3:40:28 AM)
print("Loading Roblox Studio+...")

local function getScript()
	local localScript = game:FindFirstChild("Roblox Studio+", true)
	if (localScript) then
		return localScript:Clone()
	end

	local insertService = game:GetService("InsertService")
	--local latestPluginVersion = insertService:GetLatestAssetVersionAsync(144358935)

	--print("Loading resources externally..\n\tVersion:", latestPluginVersion)
	print("Loading resources externally..")

	local publishedPlugin = insertService:LoadAsset(144358935):GetChildren()[1] --insertService:LoadAssetVersion(latestPluginVersion):GetChildren()[1]
	if (publishedPlugin and publishedPlugin:IsA("Script")) then
		return publishedPlugin
	else
		error("Failed to load 'script' global (got " .. tostring(publishedPlugin or "nil") .. ".)")
	end
end

-- For local development...
local isDevelopmentPlugin = getfenv()["script"] == nil
if (isDevelopmentPlugin) then
	--print("Loading local development resources...")
	getfenv()["script"] = getScript()
end

local virtualPlugin = require(script.Modules.VirtualPlugin)(plugin, isDevelopmentPlugin)

local features = script.Features

local featureImport = {
	require(features.Layers),
	require(features.MouseFilter),
	require(features.SelectionUndo),
	require(features.Weld),
	require(features.CodeSync)
}

for n, feature in pairs(featureImport) do
	feature(virtualPlugin)
end

print("Roblox Studio+ loaded")

-- WebGL3D
