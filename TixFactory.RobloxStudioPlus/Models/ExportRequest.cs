using System.Collections.Generic;
using System.Runtime.Serialization;

namespace TixFactory.RobloxStudioPlus
{
	[DataContract]
	public class ExportRequest
	{
		[DataMember(Name = "location")]
		public string Location { get; set; }

		[DataMember(Name = "exportData")]
		public ICollection<RobloxInstance> ExportData { get; set; }
	}
}
