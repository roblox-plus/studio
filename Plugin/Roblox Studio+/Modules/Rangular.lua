-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
-- TODO: Document
local componentStore = require(script.ComponentService.ComponentStore)
local componentService = require(script.ComponentService)
local attributeRegistrar = require(script.AttributeRegistrar)

local rangular = {
	themes = {},
	defaultTheme = script.StyleService.Themes.Dark,
	instance = script,

	registerComponent = function(rangular, component, ignoreIfDuplicate)
		componentStore:createComponent(component, ignoreIfDuplicate)
	end,

	registerAttributes = function(rangular, attributeModuleScripts, ignoreDuplicates)
		attributeRegistrar:registerAttributes(attributeModuleScripts, ignoreDuplicates)
	end,

	bootstrap = function(rangular, parent, componentName, args, theme)
		local themeModule = rangular.defaultTheme

		if (typeof(theme) == "Instance") then
			if (theme:IsA("ModuleScript")) then
				themeModule = theme
				theme = nil
			elseif (not theme:IsA("ObjectValue")) then
				error("Theme must either be an ObjectValue, or a ModuleScript.")
			end
		elseif (theme) then
			error("Theme must either be an ObjectValue, or a ModuleScript.")
		end

		if (not theme) then
			theme = Instance.new("ObjectValue")
			theme.Name = "Theme"
			theme.Value = themeModule
		end

		local component = componentService:bootstrapComponent({
			instance = parent
		}, componentName, args, theme)

		return {
			component = component
		}
	end
}

for n, theme in pairs(script.StyleService.Themes:GetChildren()) do
	rangular.themes[theme.Name] = theme
end

for n, component in pairs(script.BuiltInComponents:GetChildren()) do
	rangular:registerComponent(component)
end

return rangular

-- WebGL3D
