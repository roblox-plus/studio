-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local studio = settings()["Studio"]

return function(controller)
	local studioTheme = studio.Theme
	local modifier = Enum.StudioStyleGuideModifier.Default
	
	if (typeof(controller.styleModifier) == "EnumItem" and controller.styleModifier.EnumType == Enum.StudioStyleGuideModifier) then
		modifier = controller.styleModifier
	end
	
	return {
		["GuiObject"] = {
			BackgroundColor3 = studioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground, modifier),
			BorderColor3 = studioTheme:GetColor(Enum.StudioStyleGuideColor.Border, modifier)
		},
		
		["TextLabel"] = {
			TextColor3 = studioTheme:GetColor(Enum.StudioStyleGuideColor.InfoText, modifier)
		},
		
		["TextButton"] = {
			TextColor3 = studioTheme:GetColor(Enum.StudioStyleGuideColor.ButtonText, modifier)
		},
		
		["TextBox"] = {
			TextColor3 = studioTheme:GetColor(Enum.StudioStyleGuideColor.BrightText, modifier)
		}
	}, {
		init = function(clearCache, destroyed)
			studio.ThemeChanged:connect(clearCache)
		end
	}
end

-- WebGL3D
