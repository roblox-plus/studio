-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local classStyles = {}

for n, classStyleModuleScript in pairs(script:GetChildren()) do
	classStyles[classStyleModuleScript.Name] = require(classStyleModuleScript)
end

return classStyles

-- WebGL3D
