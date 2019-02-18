-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
return {
	creatInstanceList = function(instanceListFactory, instance)
		local instanceAddedEvent = Instance.new("BindableEvent")
		local instanceRemovedEvent = Instance.new("BindableEvent")
		local instances = {}
		
		local instanceList = {
			instanceAdded = instanceAddedEvent.Event,
			instanceRemoved = instanceRemovedEvent.Event,
			
			get = function(instanceList, validator)
				local list = {}
				
				for k, v in pairs(instances) do
					if (validator(v)) then
						table.insert(list, v)
					end
				end
				
				return list
			end,
			
			add = function(instanceList, item)
				if (not instances[item]) then
					instances[item] = item
					instanceAddedEvent:Fire(item)
				end
			end,
			
			remove = function(instanceList, descendant)
				if (instances[descendant]) then				
					instances[descendant] = nil
					instanceRemovedEvent:Fire(descendant)
				end
			end
		}
		
		if (instance) then
			instance.DescendantRemoving:connect(function(descendant)
				instanceList:remove(descendant)
			end)
		end
		
		return instanceList
	end
}

-- WebGL3D
