-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
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
