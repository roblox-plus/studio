-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
function add(tab, val, ind, forceKey)
	if (ind ~= nil) then
		if (typeof(ind) == "number" and not forceKey) then
			table.insert(tab, ind, val)
		else
			local originalValue = rawget(tab, ind)
			if (originalValue == val) then
				return
			end
			
			rawset(tab, ind, val)
		end
	else
		table.insert(tab, val)
		ind = #tab
	end
	
	tab.valueAdded:Fire(ind, val)
end

function remove(tab, ind, forceKey)
	local originalValue = rawget(tab, ind)
	if (originalValue == nil) then
		return
	end
	
	if(typeof(ind) == "number" and not forceKey) then
		table.remove(tab, ind)
	else
		tab[ind] = nil
	end
	
	tab.valueRemoved:Fire(ind, originalValue)
end

function push(tab, ...)
	for i, v in pairs({ ... }) do
		table.insert(tab, v)
	end
end

return {
	__index = function(tab, ind)
		if (ind == "add") then
			return add
		elseif (ind == "remove") then
			return remove
		elseif (ind == "push") then
			return push
		elseif (ind == "valueAdded" or ind == "valueRemoved") then
			local event = rawget(tab, ind)
			
			if (typeof(event) ~= "Instance" or not event:IsA("BindableEvent")) then 
				if (event ~= nil) then
					warn("Overriding key " .. ind .. " with BindableEvent")
				end
				
				event = Instance.new("BindableEvent")
				event.Name = ind
				
				rawset(tab, ind, event)
			end
			
			return event
		end
		
		return rawget(tab, ind)
	end
}

-- WebGL3D
