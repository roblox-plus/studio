using System;
using System.IO;
using System.Linq;

namespace TixFactory.RobloxStudioPlus
{
	public class Program
	{
		private const int _DefaultPort = 26337;
		private const string _SafeDirectory = @"E:\Workspace\Public\Roblox Studio+\Plugin";

		private readonly IWebServer _WebServer;
		private readonly IServerWindow _ServerWindow;

		public Program(IWebServer webServer, IServerWindow serverWindow)
		{
			_WebServer = webServer ?? throw new ArgumentNullException(nameof(webServer));
			_ServerWindow = serverWindow ?? throw new ArgumentNullException(nameof(serverWindow));
		}

		[STAThread]
		public static void Main(string[] args)
		{
			if (!args.Any() || !int.TryParse(args[0], out var port))
			{
				port = _DefaultPort;
			}

			var safeDirectory = _SafeDirectory;
			if (args.Length == 2 && !string.IsNullOrWhiteSpace(args[1]))
			{
				safeDirectory = args[1];
			}

			var serverWindow = new ServerWindow();
			var requestHandler = new RequestHandler(serverWindow, safeDirectory);
			var connectionHandler = new ConnectionHandler(requestHandler);
			var webServer = new WebServer(connectionHandler, port);

			var program = new Program(webServer, serverWindow);
			program.Run();
		}

		public void Run()
		{
			_WebServer.Start();
			_ServerWindow.Run();
			_WebServer.Dispose();
		}
	}
}
