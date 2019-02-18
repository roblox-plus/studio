-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local instanceCreationOverrides = {}

for n, overrideModuleScript in pairs(script:GetChildren()) do
	instanceCreationOverrides[overrideModuleScript.Name] = require(overrideModuleScript)
end

return instanceCreationOverrides

-- WebGL3D
