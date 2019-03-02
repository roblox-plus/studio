-- CodeSync: ModuleScript (2/18/2019 3:40:28 AM)
local httpService = game:GetService("HttpService")
local serverHost = "http://localhost:26337"

local function sendRequest(path, requestBody)
	local response = httpService:RequestAsync({
		Url = serverHost .. "/code-sync/" .. path,
		Method = "POST",
		Body = httpService:JSONEncode(requestBody)
	})

	local success, responseBody = pcall(function()
		return httpService:JSONDecode(response.Body)
	end)

	if (success) then
		if (responseBody.error) then
			error(responseBody.error)
		elseif (not response.Success) then
			error("Failed to connecto sync server. (" .. response.StatusCode .. ": " .. response.StatusMessage .. ")")
		end
	end

	return responseBody
end

return {
	import = function(syncService, location)
		return sendRequest("import", {
			location = location
		})
	end,

	export = function(syncService, exportTable, location)
		local exportResult = sendRequest("export", {
			location = location,
			exportData = exportTable
		})

		return exportResult.success
	end,

	openFileExplorer = function(syncService, location)
		sendRequest("openFileExplorer", {
			location = location
		})
	end,

	selectFolderPath = function(syncService)
		local result = sendRequest("selectFolderPath", {})
		return result.location
	end
}

-- WebGL3D
