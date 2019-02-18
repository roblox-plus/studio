using System;
using System.Windows.Forms;

namespace TixFactory.RobloxStudioPlus.Window
{
	public partial class MainWindow : Form
	{
		public MainWindow()
		{
			InitializeComponent();
		}
		
		protected override void OnLoad(EventArgs e)
		{
			Visible = false; // Hide form window.
			ShowInTaskbar = false; // Remove from taskbar.
			Opacity = 0;
			//Hide();

			base.OnLoad(e);
		}
	}
}
