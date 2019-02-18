-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local assertType = require(script.Parent.Parent.Parent.StyleService.CascadePropertyApplier.AssertType)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)
local attributeValueParser = require(script.Parent.Parent.AttributeValueParser)

return {
	["type"] = attributeTypes.compile,
	["priority"] = math.huge,
	
	trigger = function(attribute, childTag, attributeValue, create, destroy, context)
		local value = attributeValueParser:parseAttributeValue(context.component.controller, attributeValue)
		assertType("value", value, "BoolValue")
		
		return {
			recompileEvent = value.Changed,
			
			compile = function()
				if (not value.Value) then
					for i, child in pairs(context.component:getChildren(childTag)) do
						destroy(i, true)
					end
				end
			end,
			
			["break"] = function()
				return not value.Value
			end
		}
	end
}

-- WebGL3D
