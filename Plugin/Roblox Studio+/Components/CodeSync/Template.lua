-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
return [[
<Frame name="MainFrame">
	<TextLabel name="Header">
		<TextLabel name="Import" ra-click="import" />
		<TextLabel name="Export" ra-click="export" />
	</TextLabel>
	<ScrollingFrame>
		<UIListLayout />
		<CodeSyncFolder ra-repeat="syncInstance,syncFolder in codeSyncMap"
						instance="syncInstance"
						folderPath="syncFolder"
						syncService="syncService"
						syncExecutor="syncExecutor"
						serializeService="serializeService" />
	</ScrollingFrame>
</Frame>
]]

-- WebGL3D
