-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
-- TODO: Write documentation on the return value
local slaxml = require(script.SLAXML.slaxdom)
local httpService = game:GetService("HttpService")
local idBase = 0


function createChild(tagName)
	local id = idBase + 1
	idBase = id
	
	return {
		id = id,
		tagName = tagName,
		attributes = {},
		children = {},
		text = ""
	}
end

function parseChildren(root, parentChild, childCreated)
	local children = {}
	
	for i, tag in pairs(root.kids) do
		if (tag.type == "element") then
			local child = createChild(tag.name)
			child.children = parseChildren(tag, child, childCreated)
			
			for n, attribute in pairs(tag.attr) do
				if (attribute.type == "attribute") then
					child.attributes[attribute.name] = attribute.value
				end
			end
			
			childCreated(child, #children + 1)
			
			table.insert(children, child)
		elseif (tag.type == "text") then
			if (parentChild) then
				parentChild.text = parentChild.text .. tag.value
			end
		end
	end
	
	return children
end

function rawParse(xml)
	return slaxml:dom(xml, { simple = true })
end


return {
	parse = function(xmlParser, xml, childCreated)
		local raw = rawParse(xml)
		
		if (childCreated) then
			assert(typeof(childCreated) == "function", "Expected 'childCreated' to be 'function' (got " .. typeof(childCreated) .. ")")
		else
			childCreated = function(child)
				-- Dummy, do nothing.
			end
		end
		
		return parseChildren(raw, nil, childCreated)
	end
}

-- WebGL3D
