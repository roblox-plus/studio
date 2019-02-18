-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local instanceCreationOverrides = {}

for n, overrideModuleScript in pairs(script:GetChildren()) do
	instanceCreationOverrides[overrideModuleScript.Name] = require(overrideModuleScript)
end

return instanceCreationOverrides

-- WebGL3D
