-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local instanceCreationOverrides = require(script.Parent.Parent.InstanceCreationOverrides)
local instanceValidationService = require(script.Parent.Parent.InstanceValidationService)

return {
	isCreatableClassName = function(instanceFactory, className)
		return instanceValidationService:isCreatableClassName(className) or instanceCreationOverrides[className] ~= nil
	end,

	createInstance = function(instanceFactory, component, childTag, parentInstance)
		local createdInstance = nil

		if (instanceCreationOverrides[childTag.tagName]) then
			createdInstance = instanceCreationOverrides[childTag.tagName](childTag, component, parentInstance)
		else
			createdInstance = Instance.new(childTag.tagName, parentInstance)
		end

		if (childTag.attributes.name) then
			createdInstance.Name = childTag.attributes.name
		end

		for i, attribute in pairs(childTag.parsedAttributes.instance) do
			attribute.attribute:trigger(createdInstance, component, attribute.value, component)
		end

		component.instanceList:add(createdInstance)

		return createdInstance
	end
}

-- WebGL3D
