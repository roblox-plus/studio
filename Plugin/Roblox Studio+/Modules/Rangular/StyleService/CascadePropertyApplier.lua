-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local assertType = require(script.Parent.Parent.Modules.AssertType)
local propertySheetLoader = require(script.PropertySheetLoader)
local propertySheetCascader = require(script.PropertySheetCascader)
local timer = require(script.Parent.Parent.Modules.Timer)

return {
	propertySheetLoader = propertySheetLoader,

	applySheets = function(cascadePropertyApplier, instance, propertySheets, parentMutable)
		assertType("instance", instance, "Instance")
		assertType("propertySheets", propertySheets, "table")
		assertType("parentMutable", parentMutable, "boolean")

		local cascadeTime = timer:start()

		local properties = propertySheetCascader:cascadeSheets(instance, propertySheets, parentMutable)
		for propertyName, propertyValue in pairs(properties) do
			local success, e = pcall(function()
				instance[propertyName] = propertyValue
			end)

			if (not success) then
				warn("Failed to set '" .. propertyName .. "' property on '" .. instance.Name .. "' (" .. instance.ClassName .. ") Does this property exist?")
			end
		end

		return properties, cascadeTime:clock(0.001)
	end
}

-- WebGL3D
