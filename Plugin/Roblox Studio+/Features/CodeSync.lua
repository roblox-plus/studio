-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local rangular = require(script.Parent.Parent.Modules.Rangular)
local syncService = require(script.SyncService)
local serializeService = require(script.SerializeService)

local codeSyncComponent = script.Parent.Parent.Components.CodeSync

rangular:registerComponent(codeSyncComponent)

return function(virtualPlugin)
	local mappingStorage = virtualPlugin.storage:create("CodeSync")
	local syncExecutor = require(script.SyncExecutor)(mappingStorage)

	local codeSync = rangular:bootstrap(nil, codeSyncComponent.Name, {
		syncService = syncService,
		serializeService = serializeService,
		syncExecutor = syncExecutor,
		pluginInstance = virtualPlugin.instance,
		toolbar = virtualPlugin.toolbar
	}, rangular.instance.StyleService.Themes.Studio)

	codeSync.component:compile()

	return {}
end

-- WebGL3D
