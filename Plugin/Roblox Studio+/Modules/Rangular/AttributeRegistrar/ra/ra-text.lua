-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)

return {
	["type"] = attributeTypes.instance,
	
	trigger = function(attribute, guiObject, activeComponent, value, instanceComponent)
		assert(guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox"), "Expected ra-text to be used with text GuiObject (got " .. guiObject.ClassName .. ")")
		assert(typeof(value) == "string", "Expected ra-text value to be string (got " .. typeof(value) .. ")")
		
		local resources = activeComponent.textResources:getTextStrings()
		local text = resources[value]
		
		guiObject.Text = tostring(text)
		
		if (typeof(text) ~= "string") then
			warn("Set text for " .. tostring(guiObject) .. " (expected string, got " .. typeof(text) .. ")")
		end
		
		return {}
	end
}

-- WebGL3D
