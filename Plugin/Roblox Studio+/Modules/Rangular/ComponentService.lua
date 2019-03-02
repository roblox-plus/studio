-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local componentStore = require(script.ComponentStore)
local componentChildTypes = require(script.ComponentChildTypes)
local styleService = require(script.Parent.StyleService)
local instanceFactory = require(script.InstanceFactory)
local instanceListFactory = require(script.Parent.InstanceListFactory)
local attributeRegistrar = require(script.Parent.AttributeRegistrar)
local attributeValueParser = require(script.Parent.AttributeRegistrar.AttributeValueParser)
local timer = require(script.Parent.Modules.Timer)
local timerPrecision = 0.001

function getStylesheets(component)
	local sheets = {}

	if (component.parent.component) then
		sheets = component.parent.component:getStylesheets()
	end

	table.insert(sheets, component.style)

	return sheets
end

function getShouldCreateValue(shouldCreate)
	if (typeof(shouldCreate) == "boolean") then
		return shouldCreate
	end

	return shouldCreate.Value
end

function destroyComponentChild(child)
	if (child.type == componentChildTypes.instance) then
		child.value:Destroy()
	elseif (child.type == componentChildTypes.component) then
		for n, componentChildren in pairs(child.value.children) do
			for i, componentChild in pairs(componentChildren) do
				destroyComponentChild(componentChild)
			end
		end

		child.value:destroy()
	else
		error("Failed to destroy component (unknown componentChildType: " .. tostring(child.type) .. ")")
	end
end

function destroy(component)
	component.styleInstance:destroy()
	component.destroyedEvent:Fire()

	for n, children in pairs(component.children) do
		for i, child in pairs(children) do
			destroyComponentChild(child)
		end
	end

	component.destroyedEvent:Destroy()
	component.compiledEvent:Destroy()
end

return {
	bootstrapComponent = function(componentService, parent, componentName, args, theme)
		local componentInformation = componentStore:getComponent(componentName)
		assert(componentInformation, "Component does not exist (" .. componentName .. ")")

		local component = {
			destroyedEvent = Instance.new("BindableEvent"),
			compiledEvent = Instance.new("BindableEvent"),

			name = componentInformation.name,
			parent = parent,
			style = componentInformation.style,
			instanceList = instanceListFactory:creatInstanceList(parent.instance),

			children = {},

			getStylesheets = getStylesheets,
			destroy = destroy,
			compile = function(component)
				local compileTimer = timer:start()

				componentService:createInstances(component, componentInformation.template, parent.instance, theme)

				local compileTime = compileTimer:clock(timerPrecision)
				component.compiledEvent:Fire(compileTime, componentInformation)
			end,
			getChildren = function(component, childTag)
				return component.children[childTag.id]
			end
		}

		component.controller = componentInformation.controller(parent.instance, args, component)
		for i, v in pairs(args) do
			if (component.controller[i] == nil) then
				component.controller[i] = v
			end
		end

		component.styleInstance = styleService:bootstrapStyle(component, theme)

		if (component.parent.component) then
			component.compiledEvent.Event:connect(function(compileTime, compiledComponentInformation)
				component.parent.component.compiledEvent:Fire(compileTime, compiledComponentInformation)
			end)
		end

		return component
	end,

	createInstance = function(componentService, component, child, parentInstance, theme, extraArgs)
		if (instanceFactory:isCreatableClassName(child.tagName)) then
			local instance = instanceFactory:createInstance(component, child, parentInstance)
			componentService:createInstances(component, child.children, instance, theme)

			return {
				["type"] = componentChildTypes.instance,
				["value"] = instance
			}
		else
			local childArgs = {}

			for attributeName, attributeValue in pairs(child.attributes) do
				local extraArgValue = attributeValueParser:parseAttributeValue(extraArgs, attributeValue, true)

				if (extraArgValue ~= nil) then
					childArgs[attributeName] = extraArgValue
				else
					childArgs[attributeName] = attributeValueParser:parseAttributeValue(component.controller, attributeValue)
				end
			end

			local childComponent = componentService:bootstrapComponent({
				instance = parentInstance,
				component = component
			}, child.tagName, childArgs, theme)

			childComponent:compile()

			for i, attribute in pairs(child.parsedAttributes.component) do
				attribute.attribute:trigger(component, attribute.value, childComponent)
			end

			local childInstances = childComponent.instanceList:get(function(child)
				return child.Parent == parentInstance
			end)

			for n, instance in pairs(childInstances) do
				if (child.attributes.name) then
					instance.Name = child.attributes.name
				end

				for i, attribute in pairs(child.parsedAttributes.instance) do
					attribute.attribute:trigger(instance, component, attribute.value, childComponent)
				end
			end

			return {
				["type"] = componentChildTypes.component,
				["value"] = childComponent
			}
		end
	end,

	createInstances = function(componentService, component, root, parentInstance, theme)
		local context = {
			component = component,
			root = root,
			parentInstance = parentInstance,
			theme = theme
		}

		for n, childTag in pairs(root) do
			component.children[childTag.id] = {}
			local attributes = {}
			local events = {}

			if (childTag.tagName == "HomePage") then
				print(childTag.tagName, #childTag.parsedAttributes.compile)
			end

			local function create(index, extraArgs)
				local children = component:getChildren(childTag)
				if (children[index]) then
					return
				end

				children[index] = componentService:createInstance(component, childTag, parentInstance, theme, extraArgs)
			end

			local function destroy(index, force)
				local children = component:getChildren(childTag)
				if (not children[index]) then
					return
				end

				destroyComponentChild(children[index])
				children[index] = nil
			end

			local function compile()
				local broken = false
				local creationOverridden = false

				for i, attribute in pairs(attributes) do
					local compileResult = attribute:compile()

					if (attribute.creationOverride) then
						creationOverridden = true
					end

					if (attribute["break"] and attribute["break"]()) then
						broken = true
						break
					end
				end

				if (broken) then
					-- Compile attribute said: Do not compile anymore, I deny your request!
				else
					if (creationOverridden) then
						-- Do nothing, another attribute will handle the creation.
					else
						create(1, {})
					end
				end
			end

			for i, attribute in pairs(childTag.parsedAttributes.compile) do
				local attributeResult = attribute.attribute:trigger(childTag, attribute.value, create, destroy, context)

				if (attributeResult.recompileEvent) then
					table.insert(events, attributeResult.recompileEvent:connect(compile))
				end

				for n, event in pairs(attributeResult.events or {}) do
					table.insert(events, event)
				end

				table.insert(attributes, attributeResult)
			end

			component.destroyedEvent.Event:connect(function()
				for n, event in pairs(events) do
					event:disconnect()
				end

				attributes = {}
				events = {}
			end)

			compile()
		end
	end
}

-- WebGL3D
