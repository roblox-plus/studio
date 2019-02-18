-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
function roundTo(n, t)
	return math.ceil(n / t) * t
end

return {
	start = function()
		local startTime = tick()
		
		return {
			clock = function(timer, precision)
				local stopTime = tick()
				local passed = (stopTime - startTime) * 1000
				
				if (precision) then
					return roundTo(passed, precision)
				else
					return passed
				end
			end
		}
	end
}

-- WebGL3D
