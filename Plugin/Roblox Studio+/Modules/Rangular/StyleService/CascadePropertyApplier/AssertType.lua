-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
function isExpectedType(actualType, expectedTypes)
	for n, expectedType in pairs(expectedTypes) do
		if (actualType == expectedType) then
			return true
		end
	end
	
	return false
end

return function(name, object, ...)
	local actualType = typeof(object)
	local expectedTypes = { ... }
	local expectedType = expectedTypes[1]
	
	-- TODO: Make assert message better (include more than one expected type)
	return assert(isExpectedType(actualType, expectedTypes), "Expected '" .. name .. "' to be '" .. expectedType .. "' (got " .. actualType .. ")")
end

-- WebGL3D
