using System.Runtime.Serialization;

namespace TixFactory.RobloxStudioPlus
{
	[DataContract]
	public class LocationRequest
	{
		[DataMember(Name = "location")]
		public string Location { get; set; }
	}
}
