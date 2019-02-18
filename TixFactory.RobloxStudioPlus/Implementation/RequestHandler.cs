using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security;
using System.Text.RegularExpressions;

namespace TixFactory.RobloxStudioPlus
{
	public class RequestHandler : IRequestHandler
	{
		private readonly IServerWindow _ServerWindow;
		private readonly string _CodeSyncDirectory;
		private readonly Regex _InformationRegex;

		public RequestHandler(IServerWindow serverWindow, string codeSyncDirectory)
		{
			if (string.IsNullOrWhiteSpace(codeSyncDirectory))
			{
				throw new ArgumentException("Value cannot be null or whitespace.", nameof(codeSyncDirectory));
			}

			if (!Directory.Exists(codeSyncDirectory))
			{
				throw new DirectoryNotFoundException("Code sync directory does not exist.");
			}

			_ServerWindow = serverWindow ?? throw new ArgumentNullException(nameof(serverWindow));
			_CodeSyncDirectory = codeSyncDirectory;
			_InformationRegex = new Regex(@"^-- CodeSync: (\w+)");
		}

		public object ProcessRequest(string requestPath, string requestBody)
		{
			object response = new { };

			switch (requestPath)
			{
				case "/code-sync/openFileExplorer":
					OpenFileExplorer(JsonConvert.DeserializeObject<LocationRequest>(requestBody));
					break;
				case "/code-sync/selectFolderPath":
					var locationRequest = requestBody == "[]" ? null : JsonConvert.DeserializeObject<LocationRequest>(requestBody);
					response = new { location = _ServerWindow.SelectFolderLocation(locationRequest?.Location ?? _CodeSyncDirectory) };
					break;
				case "/code-sync/import":
					var requestModel = JsonConvert.DeserializeObject<LocationRequest>(requestBody);
					response = Import(requestModel?.Location);
					break;
				case "/code-sync/export":
					Export(JsonConvert.DeserializeObject<ExportRequest>(requestBody));
					response = new { success = true };
					break;
				default:
					throw new NotImplementedException("Unknown request path.");
			}

			return response;
		}

		private void OpenFileExplorer(LocationRequest request)
		{
			if (request == null)
			{
				throw new ArgumentNullException(nameof(request));
			}

			if (Directory.Exists(request.Location))
			{
				Process.Start("explorer.exe", request.Location);
			}
			else
			{
				throw new DirectoryNotFoundException();
			}
		}

		private ICollection<RobloxInstance> Import(string location)
		{
			if (string.IsNullOrWhiteSpace(location))
			{
				throw new ArgumentException("Value cannot be null or whitespace.", nameof(location));
			}

			if (!Directory.Exists(location))
			{
				throw new DirectoryNotFoundException();
			}

			if (!location.StartsWith(_CodeSyncDirectory))
			{
				throw new SecurityException("Directory not approved for syncing.");
			}

			var items = new List<RobloxInstance>();
			var scannedDirectories = new HashSet<string>();
			
			foreach(var file in Directory.GetFiles(location))
			{
				if (file.EndsWith(".lua"))
				{
					var fileContents = File.ReadAllText(file);
					var className = "ModuleScript";
					var classNameMatch = _InformationRegex.Match(fileContents);

					if (classNameMatch.Success)
					{
						var proposedClassName = classNameMatch.Groups[1].ToString();
						if (proposedClassName == "Script" || proposedClassName == "LocalScript")
						{
							className = proposedClassName;
						}

						fileContents = StripSource(fileContents);
					}

					var instanceName = Path.GetFileNameWithoutExtension(file);
					var script = CreateInstance(instanceName, className);
					script.Properties.Add("Source", fileContents);

					items.Add(script);

					var directory = $"{location}\\{instanceName}";
					if (Directory.Exists(directory))
					{
						script.Children = Import(directory);
						scannedDirectories.Add(directory);
					}
				}
				else if (file.EndsWith(".xml") || file.EndsWith(".md"))
				{
					var fileContents = File.ReadAllText(file);
					var instanceName = Path.GetFileNameWithoutExtension(file);
					var script = CreateInstance(instanceName, "ModuleScript");

					script.Properties.Add("Source", $"return [===[{fileContents.Trim()}]===]\n");

					items.Add(script);
				}
			}

			foreach (var directory in Directory.GetDirectories(location).Where(d => !scannedDirectories.Contains(d)))
			{
				if (directory.Contains("\\."))
				{
					continue;
				}

				var folder = CreateInstance(Path.GetFileName(directory), "Folder");
				folder.Children = Import(directory);

				items.Add(folder);
			}

			return items;
		}

		private void Export(ExportRequest request)
		{
			if (request == null)
			{
				throw new ArgumentNullException(nameof(request));
			}

			if (!Directory.Exists(request.Location))
			{
				throw new DirectoryNotFoundException();
			}

			if (!request.Location.StartsWith(_CodeSyncDirectory))
			{
				throw new SecurityException("Directory not approved for syncing.");
			}

			var expectedDirectories = new List<string>();
			var expectedFiles = new List<string>();

			foreach (var robloxInstance in request.ExportData)
			{
				if (robloxInstance.Name.StartsWith(".") || string.IsNullOrWhiteSpace(robloxInstance.Name))
				{
					continue;
				}
				
				var directory = $"{request.Location}\\{robloxInstance.Name}";

				switch (robloxInstance.ClassName)
				{
					case "Script":
					case "LocalScript":
					case "ModuleScript":
						if (robloxInstance.Properties.TryGetValue("Source", out var sourceValue) && sourceValue is string source)
						{
							var strippedSource = StripSource(source);
							var file = $"{directory}.lua";

							expectedFiles.Add(file);
							
							if (File.Exists(file))
							{
								var originalContents = StripSource(File.ReadAllText(file));
								if (originalContents == strippedSource)
								{
									break;
								}
							}
							
							File.WriteAllText(file, $"-- CodeSync: {robloxInstance.ClassName} ({DateTime.UtcNow}){Environment.NewLine}{strippedSource}");
						}

						break;
					case "Folder":
						break;
					default:
						// TODO: Unsupport instance type warning
						continue;
				}


				if (robloxInstance.Children.Any() || robloxInstance.ClassName == "Folder")
				{
					var exportRequest = new ExportRequest
					{
						Location = directory,
						ExportData = robloxInstance.Children
					};

					expectedDirectories.Add(exportRequest.Location);
					if (!Directory.Exists(exportRequest.Location))
					{
						Directory.CreateDirectory(exportRequest.Location);
					}

					Export(exportRequest);
				}
			}

			// Cleanup on export.
			foreach (var file in Directory.GetFiles(request.Location).Where(f => !expectedFiles.Contains(f)))
			{
				File.Delete(file);
			}

			foreach (var directory in Directory.GetDirectories(request.Location).Where(d => !expectedDirectories.Contains(d)))
			{
				Directory.Delete(directory, true);
			}
		}

		private string StripSource(string source)
		{
			if (_InformationRegex.IsMatch(source))
			{
				var splitSource = source.Split('\n');
				source = string.Join("\n", splitSource.Skip(1));
			}

			return source;
		}

		private RobloxInstance CreateInstance(string name, string className)
		{
			var instance = new RobloxInstance();

			instance.ClassName = className;
			instance.Name = name;
			instance.Properties = new Dictionary<string, object>();
			instance.Children = new List<RobloxInstance>();

			return instance;
		}
	}
}
