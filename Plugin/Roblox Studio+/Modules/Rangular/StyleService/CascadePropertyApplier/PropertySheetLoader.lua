-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local httpService = game:GetService("HttpService")
local assertType = require(script.Parent.AssertType)
local selectorService = require(script.Parent.SelectorService)
local propertySheetCache = {}
local loadedPropertySheets = {}
local sheetInitializations = {}


function parsePropertySheet(propertySheet, parentSelector)
	local parsedPropertySheet = {}
	local descendantSheets = {}
	
	for propertyName, propertyValue in pairs(propertySheet) do
		if (typeof(propertyValue) == "table") then
			local selectors = selectorService:parse(propertyName, parentSelector)
			local rule = {
				selectors = selectors,
				properties = propertyValue
			}
			
			table.insert(parsedPropertySheet, rule)
			
			for i, v in pairs(rule.properties) do
				if (typeof(v) == "table") then
					rule.properties[i] = nil
					
					for selectorIndex, selector in pairs(rule.selectors) do
						for n, descendantPropertySheet in pairs(parsePropertySheet({
							[i] = v
						}, selector)) do
							table.insert(descendantSheets, descendantPropertySheet)
						end
					end
				end
			end
		end
	end
	
	for n, descendantSheet in pairs(descendantSheets) do
		table.insert(parsedPropertySheet, descendantSheet)
	end
	
	return parsedPropertySheet
end

function loadPropertySheet(propertySheetModuleScript)
	local success, propertySheetLoader = pcall(function()
		return require(propertySheetModuleScript)
	end)
	
	if (not success) then
		warn("Failed to load propertySheet (" .. tostring(propertySheetModuleScript) .. "): " .. tostring(propertySheetLoader))
		propertySheetLoader = {}
	end
	
	assertType("propertySheetLoader", propertySheetLoader, "function", "table")
	
	if (typeof(propertySheetLoader) == "table") then
		return function(args)
			return propertySheetLoader
		end
	end
	
	return propertySheetLoader
end


return {
	getPropertySheet = function(propertySheetLoader, propertySheetModuleScript, args)
		assertType("propertySheetModuleScript", propertySheetModuleScript, "Instance")
		assert(propertySheetModuleScript:IsA("ModuleScript"), "Expected propertySheetModuleScript to be ModuleScript (got " .. typeof(propertySheetModuleScript.ClassName) .. ")")
		
		propertySheetCache[propertySheetModuleScript] = propertySheetCache[propertySheetModuleScript] or {}
		
		local cachedSheet = propertySheetCache[propertySheetModuleScript][args]
		
		if (cachedSheet) then
			return cachedSheet, true
		end
		
		local propertySheetLoader = loadPropertySheet(propertySheetModuleScript)
		
		local loadedPropertySheet, propertySheetConfiguration = propertySheetLoader(args)
		loadedPropertySheet = parsePropertySheet(loadedPropertySheet)
		assertType("loadedPropertySheet", loadedPropertySheet, "table")
		
		local cacheClearedEvent = Instance.new("BindableEvent")
		cacheClearedEvent.Name = "CacheCleared"
		
		local clearCacheFunction = Instance.new("BindableFunction", cacheClearedEvent)
		clearCacheFunction.Name = "ClearCache"
		clearCacheFunction.OnInvoke = function()
			loadedPropertySheet = nil
		end
		
		local destroyedEvent = Instance.new("BindableEvent", cacheClearedEvent)
		destroyedEvent.Name = "Destroyed"
		
		local result = {
			destroyed = destroyedEvent.Event,
			cacheCleared = cacheClearedEvent.Event,
			
			configuration = propertySheetConfiguration,
			
			getSheet = function()
				if (not loadedPropertySheet) then
					local sheet = propertySheetLoader(args)
					loadedPropertySheet = parsePropertySheet(sheet)
				end
				
				return loadedPropertySheet
			end,
			
			destroy = function()
				destroyedEvent:Fire()
				cacheClearedEvent:Destroy()
				
				propertySheetCache[propertySheetModuleScript][args] = nil
			end
		}
		
		propertySheetCache[propertySheetModuleScript][args] = result
		
		if (propertySheetConfiguration) then
			assertType("propertySheetConfiguration", propertySheetConfiguration, "table")
			
			if (propertySheetConfiguration.init) then
				assertType("init", propertySheetConfiguration.init, "function")
					
				local cacheEvents = propertySheetConfiguration.init(function()
					loadedPropertySheet = nil
					cacheClearedEvent:Fire()
				end, destroyedEvent.Event)
				
				result.destroyed:connect(function()
					for n, event in pairs(cacheEvents) do
						event:disconnect()
					end
				end)
			end
		else
			propertySheetConfiguration = {}
		end
		
		return result, false
	end
}

-- WebGL3D
	