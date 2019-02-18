-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local assertType = require(script.Parent.StyleService.CascadePropertyApplier.AssertType)
local register = {}

local attributeRegistrar = {
	types = require(script.AttributeTypes),
	
	getAttribute = function(attributeRegistrar, attributeName)
		return register[attributeName]
	end,
	
	registerAttribute = function(attributeRegistrar, attributeModuleScript, ignoreIfDuplicate)
		assert(typeof(attributeModuleScript) == "Instance", "Expected attributeModuleScript to be ModuleScript (got " .. typeof(attributeModuleScript) .. ")")
		assert(attributeModuleScript:IsA("ModuleScript"), "Expected attributeModuleScript to be ModuleScript (got " .. typeof(attributeModuleScript.ClassName) .. ")")
		
		if (register[attributeModuleScript.Name]) then
			if (ignoreIfDuplicate) then
				return
			end
			
			error("Duplicate registration of attribute: " .. tostring(attributeModuleScript))
		end
		
		local attribute = require(attributeModuleScript)
		assertType("attribute", attribute, "table")
		
		attribute.name = attributeModuleScript.Name
		attribute.priority = attribute.priority or 0
		
		register[attributeModuleScript.Name] = attribute
	end,
	
	registerAttributes = function(attributeRegistrar, attributeModuleScripts, ignoreDuplicates)
		assertType("attributeModuleScripts", attributeModuleScripts, "table", "Instance")
		
		if (typeof(attributeModuleScripts) == "Instance") then
			attributeRegistrar:registerAttributes(attributeModuleScripts:GetChildren(), ignoreDuplicates)
		else
			for n, attribute in pairs(attributeModuleScripts) do
				attributeRegistrar:registerAttribute(attribute, ignoreDuplicates)
			end
		end
	end
}


attributeRegistrar:registerAttributes(script.ra)
attributeRegistrar:registerAttributes(script.custom)


return attributeRegistrar

-- WebGL3D
