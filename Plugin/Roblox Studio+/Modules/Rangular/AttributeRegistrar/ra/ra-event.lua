-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local assertType = require(script.Parent.Parent.Parent.Modules.AssertType)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)
local attributeValueParser = require(script.Parent.Parent.AttributeValueParser)
local eventContextProvider = require(script.Parent.Parent.EventContextProvider)

return {
	["type"] = attributeTypes.instance,
	trigger = function(attribute, instance, activeComponent, value, instanceComponent)
		local eventName, handlerName = value:match("%s*(%w+)%s*,%s*(.+)%s*")
		assert(
			eventName and handlerName,
			'Expected ra-event value to be in format: eventName,handlerName (raw: "' .. value .. '")'
		)

		handler = attributeValueParser:parseAttributeValue(activeComponent.controller, handlerName)
		assertType("handlerName", handler, "function")

		instance[eventName]:connect(
			function(...)
				handler(eventContextProvider:buildEventContext(instanceComponent, instance), ...)
			end
		)

		return {}
	end
}

-- WebGL3D
