-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local assertType = require(script.Parent.Parent.Parent.Modules.AssertType)
local selectorService = require(script.Parent.SelectorService)

return {
	cascadeSheets = function(propertySheetCascader, instance, propertySheets, parentMutable)
		assertType("instance", instance, "Instance")
		assertType("propertySheets", propertySheets, "table")
		assertType("parentMutable", parentMutable, "boolean")

		local properties = {}

		for n, propertySheet in pairs(propertySheets) do
			for i, propertySheetValue in pairs(propertySheet:getSheet()) do
				for selectorIndex, selector in pairs(propertySheetValue.selectors) do
					if (selectorService:isMatch(instance, selector, parentMutable)) then
						for propertyName, propertyValue in pairs(propertySheetValue.properties) do
							properties[propertyName] = propertyValue
						end

						break
					end
				end
			end
		end

		return properties
	end
}

-- WebGL3D
