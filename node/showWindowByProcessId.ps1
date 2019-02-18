param ([Int32]$processId)

function Show-Process($Process, [Switch]$Maximize)
{
  $sig = '
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
  '
  
  $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
  $hwnd = $process.MainWindowHandle
  $null = $type::ShowWindowAsync($hwnd, 4) # 3 for Maximize, 4 for leave alone
  $null = $type::SetForegroundWindow($hwnd) 
}

Show-Process -Process (Get-Process -Id $processId)

# WebGL3D