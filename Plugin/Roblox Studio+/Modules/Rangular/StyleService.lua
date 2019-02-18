-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local classStyles = script.ClassStyles
local cascadePropertyApplier = require(script.CascadePropertyApplier)
local assertType = require(script.Parent.Modules.AssertType)

-- Indexes should not be tampered with without insert code order being rearranged below.
local classStyleArgs, classStyleIndex = {}, 1
local themeIndex = 2


function getPropertySheet(sheetModuleScript, sheetArgs)
	local sheet = cascadePropertyApplier.propertySheetLoader:getPropertySheet(sheetModuleScript, sheetArgs)
	return sheet
end

function getPropertySheets(component)
	local sheets = {}
	
	if (component.parent.component) then
		sheets = getPropertySheets(component.parent.component)
	end
	
	table.insert(sheets, 1, getPropertySheet(component.style, component.controller))
	
	return sheets
end

function validator()
	return true
end

function applySheets(item, propertySheets, styleAppliedEvent)
	local properties, applyTime = cascadePropertyApplier:applySheets(item, propertySheets, false)
	styleAppliedEvent:Fire(item, properties, applyTime)
end


return {
	bootstrapStyle = function(styleService, component, theme)
		assertType("component", component, "table")
		assertType("theme", theme, "Instance")
		assert(theme:IsA("ObjectValue"), "Expected 'theme' to be 'ObjectValue' (got " .. theme.ClassName .. ")")
		
		local styleAppliedEvent = Instance.new("BindableEvent")
		styleAppliedEvent.Name = "StyleApplied"
		
		local enabledState = Instance.new("BoolValue", styleAppliedEvent)
		enabledState.Value = true
		enabledState.Name = "Enabled"
		
		local propertySheets = getPropertySheets(component)
		local hasTheme = theme.Value and theme.Value:IsA("ModuleScript")
		local events = {}
		local destroyed = false
		local pendingApply = false
		local pendingItemApply = {}
		
		table.insert(propertySheets, classStyleIndex, getPropertySheet(classStyles, classStyleArgs))
		
		if (hasTheme) then
			table.insert(propertySheets, themeIndex, getPropertySheet(theme.Value, component.controller))
		end
		
		local styleInstance = {
			propertySheets = propertySheets,
			applied = styleAppliedEvent.Event,
			enabled = enabledState,
			
			apply = function()
				if (destroyed) then
					warn("Attempt to apply propertySheets on destroyed styleInstance.")
					return
				end
				
				if (enabledState.Value) then
					pendingApply = false
					pendingItemApply = {}
					
					for n, item in pairs(component.instanceList:get(validator)) do
						applySheets(item, propertySheets, styleAppliedEvent)
					end
				else
					pendingApply = true
				end
			end,
			
			registerPropertySheet = function(styleInstance, propertySheet)
				if (destroyed) then
					warn("Attempt to register propertySheet on destroyed styleInstance.")
					return
				end
				
				if (events[propertySheet]) then
					warn("Attempt to double register propertySheet.")
				else
					events[propertySheet] = propertySheet.cacheCleared:connect(styleInstance.apply)
				end
			end,
			
			unregisterPropertySheet = function(styleInstance, propertySheet)
				if (destroyed) then
					warn("Attempt to unregister propertySheet on destroyed styleInstance.")
					return
				end
				
				if (events[propertySheet]) then
					events[propertySheet]:disconnect()
					events[propertySheet] = nil
				else
					warn("Attempt to unregister a propertySheet that isn't registered.")
				end
			end,
			
			destroy = function()
				destroyed = true
				
				for n, event in pairs(events) do
					event:disconnect()
				end
				
				styleAppliedEvent:Destroy()
				
				events = {}
			end
		}
		
		for n, propertySheet in pairs(propertySheets) do
			styleInstance:registerPropertySheet(propertySheet)
		end
		
		events[theme] = theme.Changed:connect(function(themeModuleScript)
			local changes = false
			
			if (hasTheme) then
				styleInstance:unregisterPropertySheet(propertySheets[themeIndex])
				table.remove(propertySheets, themeIndex)
				hasTheme = false
				changes = true
			end
			
			if (themeModuleScript and themeModuleScript:IsA("ModuleScript")) then
				local propertySheet = getPropertySheet(themeModuleScript, component.controller)
				table.insert(propertySheets, themeIndex, propertySheet)
				styleInstance:registerPropertySheet(propertySheet)
				hasTheme = true
				changes = true
			end
			
			if (changes) then
				styleInstance:apply()
			end
		end)
		
		local function applyToItem(item)
			if (enabledState.Value) then
				applySheets(item, propertySheets, styleAppliedEvent)
			else
				pendingItemApply[item] = true
			end
		end
		
		events[component.instanceList] = component.instanceList.instanceAdded:connect(applyToItem)
		
		events[enabledState] = enabledState.Changed:connect(function(enabled)
			if (enabled) then
				if (pendingApply) then
					styleInstance:apply()
				else
					for item, b in pairs(pendingItemApply) do
						applySheets(item, propertySheets, styleAppliedEvent)
					end
					
					pendingItemApply = {}
				end
			end
		end)
		
		for i, instance in pairs(component.instanceList:get(validator)) do
			applyToItem(instance)
		end
		
		return styleInstance
	end
}

-- WebGL3D
