using Newtonsoft.Json;
using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;

namespace TixFactory.RobloxStudioPlus
{
	public class ConnectionHandler : IConnectionHandler
	{
		private readonly IRequestHandler _RequestHandler;

		public ConnectionHandler(IRequestHandler requestHandler)
		{
			_RequestHandler = requestHandler ?? throw new ArgumentNullException(nameof(requestHandler));
		}

		public void HandleListenerContext(HttpListenerContext listenerContext)
		{
			Console.WriteLine($"Request from: {listenerContext.Request.RemoteEndPoint?.Address}\n\tPath: {listenerContext.Request.Url.AbsolutePath}");

			Task.Run(() =>
			{
				listenerContext.Response.ContentType = "application/json";
				listenerContext.Response.StatusCode = 200;

				object response;

				try
				{
					using (var requestStream = new StreamReader(listenerContext.Request.InputStream))
					{
						var requestBody = requestStream.ReadToEnd();
						response = _RequestHandler.ProcessRequest(listenerContext.Request.Url.AbsolutePath, requestBody);
					}
				}
				catch (Exception e)
				{
					response = new
					{
						error = e.ToString()
					};
					listenerContext.Response.StatusCode = 500;
				}

				var responseBuffer = System.Text.Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(response));
				listenerContext.Response.OutputStream.Write(responseBuffer, 0, responseBuffer.Length);
				listenerContext.Response.OutputStream.Close();
			});
		}
	}
}
