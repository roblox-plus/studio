-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local classNameCache = {}

return {
	isCreatableClassName = function(instanceValidationService, className)
		if (classNameCache[className] ~= nil) then
			return classNameCache[className]
		end
		
		classNameCache[className] = pcall(function()
			return Instance.new(className)
		end)
		
		return classNameCache[className]
	end
}

-- WebGL3D
