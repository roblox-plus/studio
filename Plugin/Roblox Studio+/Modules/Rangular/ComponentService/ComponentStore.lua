-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local textResourceProvider = require(script.Parent.Parent.TextResourceProvider)
local xmlParser = require(script.Parent.Parent.XmlParser)
local attributeRegistrar = require(script.Parent.Parent.AttributeRegistrar)

function loadExternalComponentResource(instance)
	assert(instance:IsA("ModuleScript"), "Expected external resource to be ModuleScript (got " .. instance.ClassName .. ")")
	return require(instance)
end

function blankController(rootGuiObjects, args)
	return {}
end

function priorityComparer(a, b)
	return a.attribute.priority > b.attribute.priority
end


local components = {}


return {
	createComponent = function(componentStore, component, ignoreIfDuplicate)
		local componentInformation = {
			name = "",
			template = "",
			style = script.BlankStyle,
			controller = blankController
		}
		
		if (typeof(component) == "Instance") then
			componentInformation.name = component.Name
		
			if (components[componentInformation.name]) then
				if (ignoreIfDuplicate) then
					return
				end
				
				error("Attempt to create duplicate component.")
			end
			
			local template = component:FindFirstChild("Template")
			local style = component:FindFirstChild("Style")
			local controller = component:FindFirstChild("Controller")
			local textResources = component:FindFirstChild("TextResources")
			local dependencies = component:FindFirstChild("Dependencies")
			
			if (template) then
				componentInformation.template = loadExternalComponentResource(template)
			end
			
			if (style) then
				componentInformation.style = style
			end
			
			if (controller) then
				componentInformation.controller = loadExternalComponentResource(controller)
			end
			
			if (textResources) then
				componentInformation.textResources = loadExternalComponentResource(textResources)(textResourceProvider)
			else
				componentInformation.textResources = textResourceProvider:createEnglishResources({})
			end
			
			if (dependencies) then
				local dependenciesList = loadExternalComponentResource(dependencies)
				
				for n, dependency in pairs(dependenciesList) do
					componentStore:createComponent(dependency, true)
				end
			end
		else
			error("Unsupported component type: Only Instance component types are supported at this time.")
		end
		
		for property, value in pairs(componentInformation) do
			assert(value, "Failed to load " .. property .. " for " .. tostring(componentInformation.name))
		end
		
		if (componentInformation.template ~= "") then
			local success, err = pcall(function()
				componentInformation.template = xmlParser:parse(componentInformation.template, function(child, n)
					child.id = tostring(child.id)
					child.parsedAttributes = {}
					
					for attributeType in pairs(attributeRegistrar.types) do
						child.parsedAttributes[attributeType] = {}
					end
					
					for attributeName, attributeValue in pairs(child.attributes) do
						local attribute = attributeRegistrar:getAttribute(attributeName)
						
						if (attribute) then
							table.insert(child.parsedAttributes[attribute.type], {
								name = attribute.name,
								value = attributeValue,
								attribute = attribute
							})
							
							child.attributes[attributeName] = nil
						end
					end
					
					for attributeType in pairs(attributeRegistrar.types) do
						table.sort(child.parsedAttributes[attributeType], priorityComparer)
					end
				end)
			end)
			
			if (not success) then
				error("Error registering component (" .. componentInformation.name .. "): " .. err)
			end
		else
			componentInformation.template = {}
		end
		
		components[componentInformation.name] = componentInformation
	end,
	
	getComponent = function(componentStore, componentName)
		return components[componentName]
	end
}


-- WebGL3D
