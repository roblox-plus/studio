using System;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

namespace TixFactory.RobloxStudioPlus
{
	public class WebServer : IWebServer
	{
		private readonly IConnectionHandler _ConnectionHandler;
		private readonly HttpListener _HttpListener;
		private bool _Disposed = false;
		private CancellationTokenSource _ConnectionCancellationToken;

		public bool Connected => _ConnectionCancellationToken?.IsCancellationRequested == false;

		public WebServer(IConnectionHandler connectionHandler, int port)
		{
			_ConnectionHandler = connectionHandler ?? throw new ArgumentNullException(nameof(connectionHandler));
			_HttpListener = new HttpListener();
			_HttpListener.Prefixes.Add($"http://+:{port}/");
		}

		public void Start()
		{
			if (_Disposed)
			{
				throw new ObjectDisposedException(nameof(WebServer));
			}

			_HttpListener.Start();
			_ConnectionCancellationToken = new CancellationTokenSource();
			Task.Run(action: ListenForRequests);
		}

		public void Stop()
		{
			if (_Disposed)
			{
				throw new ObjectDisposedException(nameof(WebServer));
			}

			_HttpListener.Stop();
			_ConnectionCancellationToken.Cancel();
		}

		public void Dispose()
		{
			if (_Disposed)
			{
				return;
			}

			Stop();
			_Disposed = true;
		}

		private void ListenForRequests()
		{
			Console.WriteLine($"Listening... {_HttpListener.Prefixes.FirstOrDefault()}");

			while (Connected)
			{
				var contextTask = _HttpListener.GetContextAsync();
				Task.WaitAll(new Task[] { contextTask }, _ConnectionCancellationToken.Token);

				if (!_ConnectionCancellationToken.IsCancellationRequested)
				{
					_ConnectionHandler.HandleListenerContext(contextTask.Result);
				}
			}

			Console.WriteLine($"Stopped listening to {_HttpListener.Prefixes.FirstOrDefault()}");
		}
	}
}
