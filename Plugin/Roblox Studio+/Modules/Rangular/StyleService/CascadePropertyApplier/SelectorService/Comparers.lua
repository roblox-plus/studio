-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local comparers = {
	["="] = function(a, b)
		local bValue = tostring(b)

		if (tostring(a) == bValue) then
			return true
		end
		
		if (typeof(a) == "EnumItem") then
			return a.Name == bValue or tostring(a.Value) == bValue
		end
		
		return false
	end,
	
	["<"] = function(a, b)
		a, b = tonumber(a), tonumber(b)
		return a and b and a < b
	end,
	
	[">"] = function(a, b)
		a, b = tonumber(a), tonumber(b)
		return a and b and a > b
	end,
	
	["<="] = function(a, b)
		a, b = tonumber(a), tonumber(b)
		return a and b and a <= b
	end,
	
	[">="] = function(a, b)
		a, b = tonumber(a), tonumber(b)
		return a and b and a >= b
	end,
	
	["*="] = function(a, b)
		local match = tostring(a):match(tostring(b))
		return match and match ~= ""
	end,
	
	["^="] = function(a, b)
		local bValue = tostring(b)
		return tostring(a):sub(1, #bValue) == bValue
	end,
	
	["$="] = function(a, b)
		local bValue = tostring(b)
		return tostring(a):sub(-#bValue) == bValue
	end
}

comparers["~="] = function(a, b)
	return not comparers["="](a, b)
end

comparers["*~="] = function(a, b)
	return not comparers["*="](a, b)
end

comparers["^~="] = function(a, b)
	return not comparers["^="](a, b)
end

comparers["$~="] = function(a, b)
	return not comparers["^="](a, b)
end


local types = {}

for key, comparer in pairs(comparers) do
	table.insert(types, key)
end

return {
	types = types,
	comparers = comparers
}

-- WebGL3D
