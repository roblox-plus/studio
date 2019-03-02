-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return {
	serialize = function(serializeService, instance)
		local topLevel = {
			scripts = {},
			children = {}
		}

		for n, o in pairs(instance:GetChildren()) do
			if (o:IsA("Script")) then
				table.insert(topLevel.scripts, {
					className = o.ClassName,
					source = o.Source
				})
			else
				local serialized = serializeService:serialize(o)
				table.insert(topLevel.children, serialized)
			end
		end

		return topLevel
	end
}

-- WebGL3D
