using System;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using TixFactory.RobloxStudioPlus.Window;

namespace TixFactory.RobloxStudioPlus
{
	public class ServerWindow : IServerWindow
	{
		private readonly MainWindow _MainWindow;

		public ServerWindow()
		{
			var mainWindow = new MainWindow();
			_MainWindow = mainWindow;
		}

		public string SelectFolderLocation(string startFolder)
		{
			string selctedFolderPath = null;
			_MainWindow.Invoke(new Action(() => selctedFolderPath = PromptSelectFolderLocation(startFolder)));
			return selctedFolderPath;
		}

		private string PromptSelectFolderLocation(string startFolder)
		{
			BringToFront();

			var folderBrowser = new FolderBrowserDialog();
			folderBrowser.ShowNewFolderButton = true;
			folderBrowser.SelectedPath = startFolder;

			var show = folderBrowser.ShowDialog(_MainWindow);

			if (show == DialogResult.OK)
			{
				if (Directory.Exists(folderBrowser.SelectedPath))
				{
					return folderBrowser.SelectedPath;
				}
			}

			return null;
		}

		public void Run()
		{
			Application.Run(_MainWindow);
		}

		private void BringToFront()
		{
			// https://stackoverflow.com/a/11941579/1663648
			_MainWindow.WindowState = FormWindowState.Minimized;
			_MainWindow.Show();
			_MainWindow.WindowState = FormWindowState.Normal;
		}
	}
}
