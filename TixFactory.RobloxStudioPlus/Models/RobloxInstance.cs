using System.Collections.Generic;
using System.Runtime.Serialization;

namespace TixFactory.RobloxStudioPlus
{
	[DataContract]
	public class RobloxInstance
	{
		[DataMember(Name = "className")]
		public string ClassName { get; set; }

		[DataMember(Name = "name")]
		public string Name { get; set; }

		[DataMember(Name = "properties")]
		public IDictionary<string, object> Properties { get; set; }

		[DataMember(Name = "children")]
		public ICollection<RobloxInstance> Children { get; set; }
	}
}
