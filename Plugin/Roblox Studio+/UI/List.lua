-- CodeSync: ModuleScript (2/18/2019 2:03:06 AM)
return {
	create = function(listFactory, scrollFrameInstance)
		local function checkSize()
			local maxY = 0
			for n, instance in pairs(scrollFrameInstance:GetChildren())do
				if(instance:IsA("GuiObject"))then
					maxY = math.max(maxY, instance.Position.Y.Offset + instance.Size.Y.Offset)
				end
			end
			
			scrollFrameInstance.CanvasSize = UDim2.new(1, 0, 0, maxY)
		end
		
		scrollFrameInstance.ChildAdded:connect(checkSize)
		scrollFrameInstance.ChildRemoved:connect(checkSize)
		checkSize()
		
		return {}
	end
}

-- WebGL3D
