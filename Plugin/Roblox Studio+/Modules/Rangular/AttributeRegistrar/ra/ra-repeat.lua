-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local attributeTypes = require(script.Parent.Parent.AttributeTypes)
local dynamicListMetatable = require(script.Parent.Parent.Parent.Modules.DynamicListMetatable)
local attributeValueParser = require(script.Parent.Parent.AttributeValueParser)

local restrictedTableKeys = {
	valueAdded = true,
	valueRemoved = true
}

function createFromCount(childTag, context, count, create, destroy, var1)
	for n = 1, count do
		create(n, {
			[var1] = n
		})
	end

	for n = #context.component:getChildren(childTag), count + 1, -1 do
		destroy(n)
	end
end

function createFromTable(childTag, context, tab, create, destroy, var1, var2)
	for n, child in pairs(context.component:getChildren(childTag)) do
		if (tab[n] == nil and not restrictedTableKeys[n]) then
			destroy(n, true)
		end
	end

	for i, v in pairs(tab) do
		if (not restrictedTableKeys[i]) then
			create(i, {
				[var1] = i,
				[var2] = v
			})
		end
	end
end

return {
	["type"] = attributeTypes.compile,

	trigger = function(attribute, childTag, attributeValue, create, destroy, context)
		local args, rawValue = attributeValue:match("(.+)%s+in%s+(.+)")
		local var1, var2 = args:match("([^,%s]+)%s*,?%s*(.*)")
		local value = attributeValueParser:parseAttributeValue(context.component.controller, rawValue)

		local recompileEvent = Instance.new("BindableEvent")
		local events = {}
		local compile = nil

		if (var2 == "") then
			if (typeof(value) == "number") then
				compile = function()
					createFromCount(childTag, context, value, create, destroy, var1)
				end

			elseif (typeof(value) == "Instance" and value:IsA("IntValue")) then
				compile = function()
					createFromCount(childTag, context, value.Value, create, destroy, var1)
				end

				table.insert(events, value.Changed:connect(compile))
			else
				error("'ra-repeat' number (or IntValue) expected (got " .. typeof(value) .. ", raw: " .. rawValue .. ")")
			end
		else
			if (typeof(value) == "table") then
				compile = function()
					createFromTable(childTag, context, value, create, destroy, var1, var2)
				end

				local valueMetatable = getmetatable(value)
				if (valueMetatable == dynamicListMetatable) then
					table.insert(events, value.valueAdded.Event:connect(compile))
					table.insert(events, value.valueRemoved.Event:connect(compile))
				end
			end
		end

		return {
			events = events,
			recompileEvent = recompileEvent.Event,
			creationOverride = true,

			compile = compile
		}
	end
}

-- WebGL3D
