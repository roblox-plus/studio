-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
local assertType = require(script.Parent.AssertType)
local comparers = require(script.Comparers)
local selectorParseCache = {}
local rawSelectorParseCache = {}
local matchCache = {}


function trim(s)
	if (not s) then
		return ""
	end
	
	return s:gsub("^%s+", ""):gsub("%s+$", "")
end

function isMatch(instance, parsedSelector, debugEnabled)
	if (parsedSelector.className and not instance:IsA(parsedSelector.className)) then
		return false
	end
	
	if (parsedSelector.name and parsedSelector.name ~= instance.Name) then
		return false
	end
	
	if (parsedSelector.directDescendant and parsedSelector.parentSelector) then
		if (not instance.Parent) then
			return false
		end
		
		if (not isMatch(instance.Parent, parsedSelector.parentSelector, debugEnabled)) then
			return false
		end
	end
	
	for propertyName, propertyValue in pairs(parsedSelector.properties) do
		local success, isMatch = pcall(function() return propertyValue:compare(instance[propertyName]) end)
		
		if (not success and debugEnabled) then
			warn("Failed to compare '" .. propertyName .. "' on '" .. tostring(instance) .. "' (" .. instance.ClassName .. ") - Does this instance have that property?")
		end
		
		if (not success or not isMatch) then
			return false
		end
	end
	
	return true
end

function parseSelector(selectorService, selector, argumentName)
	if (typeof(selector) == "table") then
		return selector
	end
	
	assertType(argumentName, selector, "string")
	return selectorService:parse(selector)
end

function canCacheSelectorMatch(parsedSelector)
	if (parsedSelector.propertyCount > 0) then
		return false
	end
	
	if (parsedSelector.parentSelector) then
		return canCacheSelectorMatch(parsedSelector.parentSelector)
	end
	
	return true
end

function stripSelectorConfiguration(selector, configurationSymbols)
	local configuration = {}
	
	for n, symbol in pairs(configurationSymbols) do
		configuration[symbol] = selector:sub(1) == symbol
		
		if (configuration[symbol]) then
			selector = selector:sub(2)
		end
	end
	
	return selector, configuration
end

function parseSingleSelector(selectorService, selector, parentSelector)
	assertType("selector", selector, "string")
	
	if (parentSelector ~= nil) then
		assertType("parentSelector", parentSelector, "table")
	end
	
	if (parentSelector and not parentSelector.key) then
		local httpService = game:GetService("HttpService")
		print(httpService:JSONEncode(parentSelector))
	end
	
	local selectorKey = parentSelector and (parentSelector.key .. "\n") or ""
	local cacheKey = selectorKey .. selector
	
	if (selectorService.cacheSelectorParse and selectorParseCache[cacheKey]) then
		return selectorParseCache[cacheKey], true
	end
	
	local properties = {}
	local propertyCount = 0
	
	local selector, configuration = stripSelectorConfiguration(selector, { "&", ">" })
	
	local propertyMatch = selector:match("%[[^%]]*%]%s*$")
	if (propertyMatch and propertyMatch ~= "") then
		selector = selector:sub(1, #selector - #propertyMatch)
		
		local propertyName, compareSymbol, propertyValue = propertyMatch:match("^%[([^=<>~]+)([=~<>]+)([^%]]+)")
		propertyName, propertyValue = trim(propertyName), trim(propertyValue)
		
		if (propertyName ~= "" and propertyValue ~= "" and comparers.comparers[compareSymbol]) then
			properties[propertyName] = {
				compare = function(property, a)
					return comparers.comparers[property.comparer](a, property.value)
				end,
				
				comparer = compareSymbol,
				value = propertyValue
			}
			
			selectorKey = selectorKey .. "[" .. propertyName .. compareSymbol .. propertyValue .. "]"
			propertyCount = propertyCount + 1
		else
			if (selectorService.debug) then
				local availableComparers = ""
				for n, symbol in pairs(comparers.types) do
					availableComparers = availableComparers .. (availableComparers == "" and "" or ", ") .. "'" .. symbol .. "'"
				end
				
				warn("Invalid property match selector: " .. propertyMatch .. "\n\tExpected format: [PropertyName = PropertyValue]\n\tAvailable comparison symbols: " .. availableComparers)
			end
		end
	end
	
	local className, name = selector:match("([^%.]*)%.?(.*)")
	
	if (className == "") then
		className = nil
	end
	
	if (name == "") then
		name = nil
	end
	
	local parsedSelector = {
		selector = selector,
		key = selectorKey .. (className or "") .. ":" .. (name or ""),
		
		parentSelector = parentSelector,
		
		parentExtension = configuration["&"],
		directDescendant = configuration[">"],
		
		className = className,
		name = name,
		properties = properties,
		
		propertyCount = propertyCount
	}
	
	if (selectorService.debug and parsedSelector.parentExtension and not parsedSelector.parentSelector) then
		warn("Parent extension selector present without parent selector specified (" .. selector .. ")")
	end
	
	if (selectorService.cacheSelectorParse) then
		selectorParseCache[cacheKey] = parsedSelector
	end
	
	return parsedSelector, false
end


return {
	["debug"] = true,
	["cacheSelectorParse"] = true,
	["cacheMatches"] = true,
	
	getSelectorCache = function()
		return selectorParseCache
	end,
	
	parse = function(selectorService, selector, parentSelector)
		if (selectorService.cacheSelectorParse and rawSelectorParseCache[selector]) then
			return rawSelectorParseCache[selector], true
		end
		
		local selectors = {}
		local parsed = {}
		
		for singleSelector in string.gmatch(selector, "([^,]+),?") do
			singleSelector = trim(singleSelector)
			
			if (parsed[singleSelector]) then
				if (selectorService.debug) then
					warn("Duplicate selector: " .. singleSelector .. " (in: \"" .. selector .. "\")")
				end
			else
				local parsedSelector, cached = parseSingleSelector(selectorService, singleSelector, parentSelector)
				parsed[singleSelector] = true
				table.insert(selectors, parsedSelector)
			end
		end
		
		if (selectorService.cacheSelectorParse) then
			rawSelectorParseCache[selector] = selectors
		end
		
		return selectors, false
	end,
	
	isMatch = function(selectorService, instance, parsedSelector, parentMutable)
		assertType("instance", instance, "Instance")
		assertType("parsedSelector", parsedSelector, "table")
		assertType("parentMutable", parentMutable, "boolean")
		
		local cacheKey = instance.ClassName .. ":" .. instance.Name .. "\n" .. parsedSelector.key
		local canCacheSelector = selectorService.cacheMatches and not parentMutable and canCacheSelectorMatch(parsedSelector)
		
		if (canCacheSelector and matchCache[cacheKey] ~= nil) then
			return matchCache[cacheKey], true
		end
		
		local match = isMatch(instance, parsedSelector, selectorService.debug)
		
		if (canCacheSelector) then
			matchCache[cacheKey] = match
		end
		
		return match, false
	end
}

-- WebGL3D
