-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local assertType = require(script.Parent.Parent.Parent.Modules.Rangular.Modules.AssertType)

return function(parentInstance, args, component)
	assertType("checked", args.checked, "Instance")
	assert(args.checked:IsA("BoolValue"), "Expected 'checked' to be 'BoolValue' (got " .. args.checked.ClassName .. ")")

	return {
		click = function()
			args.checked.Value = not args.checked.Value
		end
	}
end

-- WebGL3D
