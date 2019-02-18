-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local assertType = require(script.Parent.Parent.StyleService.CascadePropertyApplier.AssertType)
--local httpService = game:GetService("HttpService")

return {
	parseAttributeValue = function(attributeValueParser, startPoint, attributeValue, ignoreInvalidPath)
		assertType("startPoint", startPoint, "table")
		assertType("attributeValue", attributeValue, "string")
		
		if (attributeValue:sub(1) == "'" and attributeValue:sub(-1) == "'") then
			return attributeValue:sub(2, -2)
		end
		
		local parsedAttributeValue = nil
		
		for pathPiece in string.gmatch(attributeValue, "([^%.]+).?") do
			if (parsedAttributeValue ~= nil) then
				parsedAttributeValue = parsedAttributeValue[pathPiece]
			else
				parsedAttributeValue = startPoint[pathPiece]
			end
			
			if (not parsedAttributeValue) then
				if (not ignoreInvalidPath) then
					warn("Invalid path:" .. attributeValue .. " (at: " .. pathPiece .. ")")
					--print(httpService:JSONEncode(startPoint))
				end
				
				break
			end
		end
		
		return parsedAttributeValue
	end
}

-- WebGL3D
