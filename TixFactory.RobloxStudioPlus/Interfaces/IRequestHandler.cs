namespace TixFactory.RobloxStudioPlus
{
	public interface IRequestHandler
	{
		object ProcessRequest(string requestPath, string requestBody);
	}
}
