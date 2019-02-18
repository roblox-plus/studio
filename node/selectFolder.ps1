Function Select-FolderDialog
{
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     
	
	$objForm = New-Object System.Windows.Forms.FolderBrowserDialog
	$Show = $objForm.ShowDialog()
	If ($Show -eq "OK")
	{
		Return $objForm.SelectedPath
	}
	Else
	{
		Write-Error "Operation cancelled by user."
	}
}

$folder = Select-FolderDialog # the variable contains user folder selection
write-host $folder