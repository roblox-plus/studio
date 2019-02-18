var fs = require("fs");
var http = require("http");
var url = require("url");
var child_process = require("child_process");

var bringToFront = function(processId) {
	child_process.spawn("powershell.exe", ["./showWindowByProcessId.ps1", processId.toString()], {});
};

var requestHandlers = {
	"/code-sync/openFileExplorer": function(requestBody) {
		return new Promise(function(resolve, reject){
			child_process.exec("start \"\" \"" + JSON.stringify(requestBody.location) + "\"", function(err, stdout, stderr){
				if (err) {
					reject(err);
					return;
				}
				
				resolve();
			});
		});
	},
	
	"/code-sync/selectFolderPath": function(requestBody) {
		return new Promise(function(resolve, reject){
			var output = "";
			var errors = "";
			
			bringToFront(process.pid);
			
			var child = child_process.spawn("powershell.exe", ["./selectFolder.ps1"], {});
			
			child.stdout.on("data",function(data){
				output += data;
			});
			
			child.stderr.on("data",function(data){
				errors += "\n" + data;
			});
			
			child.on("end", function(){
				if (errors) {
					reject(errors);
				}else{
					resolve(output);
				}
			});
			
			//bringToFront(child.pid);
		});
	}
};

var requestFailed = function(response, e){
	console.error("Request failed:", e);
	response.writeHead(500, { "Content-Type": "application/json" });
	response.write("{}");
	response.end();
};

http.createServer(function(request, response) {
	var parsedUrl = url.parse(request.url);
	var requestBody = "";
	
	request.on("data", function(chunk){
		requestBody += chunk;
	});
	
	request.on("end", function(){
		try {
			var parsedRequestBody = JSON.parse(requestBody);
			console.log("Request received:", parsedUrl.pathname, "\n", parsedRequestBody);
			
			var requestHandler = requestHandlers[parsedUrl.pathname];
			// TODO: Validate existence
			
			requestHandler(parsedRequestBody).then(function(responseJson){
				response.writeHead(200, { "Content-Type": "application/json" });
				response.write(JSON.stringify(responseJson || {}));
				response.end();
			}).catch(function(e) {
				requestFailed(response, e);
			});
		} catch (e) {
			requestFailed(response, e);
		}
	});
}).listen(26337);

console.log("Server started");
