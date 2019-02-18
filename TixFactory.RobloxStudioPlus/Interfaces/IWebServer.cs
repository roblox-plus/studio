using System;

namespace TixFactory.RobloxStudioPlus
{
	public interface IWebServer : IDisposable
	{
		bool Connected { get; }

		void Start();
		void Stop();
	}
}
