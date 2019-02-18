-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local attributeValueParser = require(script.Parent.Parent.AttributeRegistrar.AttributeValueParser)

local function getComponentIdentifier(component)
	return "component: " .. component.name .. ", instance: " .. script.Name .. ""
end

function isExpectedType(actualType, expectedTypes)
	for n, expectedType in pairs(expectedTypes) do
		if (actualType == expectedType) then
			return true
		end
	end
	
	return false
end

local function assertType(component, name, value, ...)
	local actualType = typeof(value)
	local expectedTypes = { ... }
	local expectedType = expectedTypes[1]
	
	assert(isExpectedType(actualType, expectedTypes), "Expected '" .. name .. "' (" .. getComponentIdentifier(component) .. ") to be '" .. expectedType .. "' (got " .. actualType .. ")")
end

local function assertClass(component, name, instance, expectedClassName)
	assertType(component, name, instance, "Instance")
	assert(instance:IsA(expectedClassName), "Expected '" .. name .. "' (" .. getComponentIdentifier(component) .. ") to be '" .. expectedClassName .. "' (got " .. instance.ClassName .. ")")
end 

local function getControllerValue(childTag, component, attributeName)
	local attributeValue = childTag.attributes[attributeName]
	return attributeValue and attributeValueParser:parseAttributeValue(component.controller, attributeValue)
end

local function toVector2(childTag, component, attributeName, required)
	local attributeValue = getControllerValue(childTag, component, attributeName)
	
	if (required) then
		assertType(component, "attributeValue", attributeValue, "Vector2")
	else
		if (attributeValue and typeof(attributeValue) ~= "Vector2") then
			warn(attributeName .. " will be ignored (" .. getComponentIdentifier(component) .. "). Expected controller value to equal Vector2 (got " .. typeof(attributeValue) .. ")")
			attributeValue = nil
		end
	end
	
	return attributeValue
end

return function(childTag, component, parentInstance)
	-- parentInstance is ignored for this class.
	
	local id = getControllerValue(childTag, component, "id")
	local title = getControllerValue(childTag, component, "title")
	local float = getControllerValue(childTag, component, "float")
	local minimumSize = toVector2(childTag, component, "minimumSize")
	local size = toVector2(childTag, component, "size", true)
	local enabledState = getControllerValue(childTag, component, "enabled")
	local overridePreviousEnabledState = getControllerValue(childTag, component, "overridePreviousEnabledState") or false
	local pluginInstance = getControllerValue(childTag, component, "plugin")
	
	assertClass(component, "plugin", pluginInstance, "Plugin")
	
	assertType(component, "title", title, "string", "Instance")
	if (typeof(title) == "Instance") then
		assertClass(component, "title", title, "StringValue")
	end
	
	assertType(component, "id", id, "string")
	assert(id ~= "", "Expected 'id' (" .. getComponentIdentifier(component) .. ") to be non-empty string (got empty string)")
	
	assertClass(component, "enabled", enabledState, "BoolValue")
	assertType(component, "overridePreviousEnabledState", overridePreviousEnabledState, "boolean")
	
	if (float) then
		assertType(component, "float", float, "EnumItem")
		assert(float.EnumType == Enum.InitialDockState, "Expected 'float' (" .. getComponentIdentifier(component) .. ") to be 'Enum.InitialDockState' (got " .. tostring(float.EnumType) .. ")")
	else
		float = Enum.InitialDockState.Float
	end
	
	local widgetInfoTable = { float, enabledState.Value, overridePreviousEnabledState, size.X, size.Y }
	if (minimumSize) then
		table.insert(widgetInfoTable, minimumSize.X)
		table.insert(widgetInfoTable, minimumSize.Y)
	end
	
	local widgetInfo = DockWidgetPluginGuiInfo.new(unpack(widgetInfoTable))
	local widget = pluginInstance:CreateDockWidgetPluginGui(id, widgetInfo)
	
	enabledState.Value = widget.Enabled
	
	enabledState.Changed:connect(function(enabled)
		widget.Enabled = enabled
	end)
	
	if (typeof(title) == "Instance") then
		widget.Title = title.Value
		
		title.Changed:connect(function(newTitle)
			widget.Title = newTitle
		end)
	else
		widget.Title = title
	end
	
	return widget
end

-- WebGL3D
