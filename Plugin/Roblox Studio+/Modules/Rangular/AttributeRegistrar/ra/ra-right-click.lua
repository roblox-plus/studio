-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)
local attributeValueParser = require(script.Parent.Parent.AttributeValueParser)

return {
	["type"] = attributeTypes.instance,
	
	trigger = function(attribute, instance, activeComponent, value, instanceComponent)
		assert(instance:IsA("GuiObject") or instance:IsA("ClickDetector"), "Expected ra-right-click to be used with GuiObject or ClickDetector (got " .. instance.ClassName .. ")")
		
		value = attributeValueParser:parseAttributeValue(activeComponent.controller, value)
		assert(typeof(value) == "function", "Expected ra-right-click value to be function (got " .. typeof(value) .. ")")
			
		local function mouseRightClick(...)
			value({
				controller = instanceComponent.controller,
				instance = instance
			}, ...)
		end
		
		if (instance:IsA("GuiObject")) then
			instance.InputEnded:connect(function(input, ...)
				if (input.UserInputType == Enum.UserInputType.MouseButton2) then
					mouseRightClick(input, ...)
				end
			end)
		elseif (instance:IsA("ClickDetector")) then
			instance.RightMouseClick:connect(mouseRightClick)
		end
		
		return {}
	end
}

-- WebGL3D
