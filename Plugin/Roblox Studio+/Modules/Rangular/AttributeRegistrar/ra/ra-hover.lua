-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)
local attributeValueParser = require(script.Parent.Parent.AttributeValueParser)
local eventContextProvider = require(script.Parent.Parent.EventContextProvider)

return {
	["type"] = attributeTypes.instance,
	trigger = function(attribute, instance, activeComponent, value, instanceComponent)
		assert(
			instance:IsA("GuiObject") or instance:IsA("ClickDetector"),
			"Expected ra-hover to be used with GuiObject or ClickDetector (got " .. instance.ClassName .. ")"
		)

		value = attributeValueParser:parseAttributeValue(activeComponent.controller, value)
		assert(typeof(value) == "function", "Expected ra-hover value to be function (got " .. typeof(value) .. ")")

		local function mouseEnter(...)
			value(eventContextProvider:buildEventContext(instanceComponent, instance), ...)
		end

		if (instance:IsA("GuiObject")) then
			instance.MouseEnter:connect(mouseEnter)
		elseif (instance:IsA("ClickDetector")) then
			instance.MouseHoverEnter:connect(mouseEnter)
		end

		return {}
	end
}

-- WebGL3D
