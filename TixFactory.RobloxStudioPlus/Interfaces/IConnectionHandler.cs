using System.Net;
using System.Net.Sockets;

namespace TixFactory.RobloxStudioPlus
{
	public interface IConnectionHandler
	{
		void HandleListenerContext(HttpListenerContext listenerContext);
	}
}
