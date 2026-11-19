# Called by the installed smoke after it has proved the runner profile is new.
param(
  [Parameter(Mandatory=$true)][string]$Exe,
  [Parameter(Mandatory=$true)][string]$SettingsPath,
  [Parameter(Mandatory=$true)][string]$EvidencePath
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $IsWindows -or $env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted') {
  throw 'Explorer restart testing requires a disposable GitHub-hosted Windows runner'
}

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class MorseCQTraySmoke {
    [StructLayout(LayoutKind.Sequential)]
    private struct IconId {
        public uint size;
        public IntPtr window;
        public uint id;
        public Guid guid;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct Rect { public int left, top, right, bottom; }

    [DllImport("shell32.dll")]
    private static extern int Shell_NotifyIconGetRect(ref IconId icon, out Rect rect);
    [DllImport("user32.dll")]
    public static extern IntPtr GetShellWindow();
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string className, string windowName);
    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr window, out uint pid);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr window);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern bool PostMessage(IntPtr window, uint message, IntPtr wParam, IntPtr lParam);

    public static uint WindowPid(IntPtr window) {
        GetWindowThreadProcessId(window, out uint pid);
        return pid;
    }

    public static bool HasIconRectangle(IntPtr window) {
        var icon = new IconId { size = (uint)Marshal.SizeOf<IconId>(), window = window, id = 1 };
        return Shell_NotifyIconGetRect(ref icon, out _) == 0;
    }

    // Inject the notification callback into our own installed window.
    public static bool InvokeTrayCallback(IntPtr window) {
        return PostMessage(window, 0x0401, new IntPtr(1), new IntPtr(0x0202));
    }
}
'@

$sessionId = (Get-Process -Id $PID).SessionId
function Get-TaskbarExplorer {
  $taskbar = [MorseCQTraySmoke]::FindWindow('Shell_TrayWnd', $null)
  $shell = [MorseCQTraySmoke]::GetShellWindow()
  if ($sessionId -eq 0 -or $taskbar -eq [IntPtr]::Zero -or $shell -eq [IntPtr]::Zero) { return }
  $explorerId = [MorseCQTraySmoke]::WindowPid($taskbar)
  if ($explorerId -eq 0 -or $explorerId -ne [MorseCQTraySmoke]::WindowPid($shell)) { return }
  $explorer = Get-Process -Id $explorerId -ErrorAction SilentlyContinue
  if ($explorer -and $explorer.ProcessName -eq 'explorer' -and $explorer.SessionId -eq $sessionId) { return $explorer }
}

function Wait-Until([scriptblock]$Condition, [int]$Seconds, [string]$Failure) {
  $deadline = [DateTime]::UtcNow.AddSeconds($Seconds)
  do {
    if (& $Condition) { return }
    Start-Sleep -Milliseconds 200
  } while ([DateTime]::UtcNow -lt $deadline)
  throw $Failure
}

$report = [ordered]@{ outcome = 'failed'; session_id = $sessionId; explorer_restarted = $false }
$app = $null
$restartRequested = $false
$savedSettings = if (Test-Path -LiteralPath $SettingsPath) { Get-Content -LiteralPath $SettingsPath -Raw }
try {
  $settings = if ($null -ne $savedSettings) { $savedSettings | ConvertFrom-Json -AsHashtable } else { @{} }
  $settings['desktop.closeToTray'] = 'true'
  New-Item -Path (Split-Path -Parent $SettingsPath) -ItemType Directory -Force | Out-Null
  $settings | ConvertTo-Json -Compress | Set-Content -LiteralPath $SettingsPath -Encoding utf8

  $app = Start-Process -FilePath $Exe -WorkingDirectory (Split-Path -Parent $Exe) -PassThru
  Wait-Until {
    $app.Refresh()
    $app.MainWindowHandle -ne [IntPtr]::Zero
  } 30 'The tray test did not find the installed app window'
  $window = $app.MainWindowHandle
  $explorer = Get-TaskbarExplorer
  if ($null -eq $explorer -or $app.SessionId -ne $sessionId) {
    $report.outcome = 'no-interactive-explorer'
    if ([MorseCQTraySmoke]::HasIconRectangle($window)) {
      $report['fallback_reason'] = 'Notification area present without a safely identified Explorer owner'
      return
    }
    if (-not $app.CloseMainWindow() -or -not $app.WaitForExit(20000) -or $app.ExitCode -ne 0) {
      throw 'Closing with no registered notification icon did not exit normally'
    }
    $report['fallback_quit_verified'] = $true
    return
  }

  if (-not $app.CloseMainWindow()) { throw 'The installed window refused the close-to-tray action' }
  Wait-Until { -not [MorseCQTraySmoke]::IsWindowVisible($window) -and -not $app.HasExited } 10 'Closing did not hide the installed app after its registration check'
  $report['native_guarded_hide_before_restart'] = $true
  $report['icon_rectangle_before_restart'] = [MorseCQTraySmoke]::HasIconRectangle($window)

  # Stop only the PID that owns both shell windows in our disposable session.
  $confirmedExplorer = Get-TaskbarExplorer
  if ($null -eq $confirmedExplorer -or $confirmedExplorer.Id -ne $explorer.Id) {
    throw 'Explorer changed before the targeted restart'
  }
  $report['explorer_before'] = $explorer.Id
  $restartRequested = $true
  Stop-Process -InputObject $explorer -Force
  if (-not $explorer.WaitForExit(10000)) { throw 'The original Explorer did not exit' }
  if (-not (Get-TaskbarExplorer)) { Start-Process "$env:WINDIR\explorer.exe" }
  Wait-Until {
    $replacement = Get-TaskbarExplorer
    $null -ne $replacement -and $replacement.Id -ne $explorer.Id
  } 30 'Explorer did not create a replacement taskbar in the same session'
  $report.explorer_restarted = $true
  $report['explorer_after'] = (Get-TaskbarExplorer).Id

  $watchDeadline = [DateTime]::UtcNow.AddSeconds(5)
  do {
    if ($app.HasExited) { throw 'The installed app exited during the Explorer restart' }
    $visible = [MorseCQTraySmoke]::IsWindowVisible($window)
    $hasRect = [MorseCQTraySmoke]::HasIconRectangle($window)
    if ($visible -or $hasRect) { break }
    Start-Sleep -Milliseconds 200
  } while ([DateTime]::UtcNow -lt $watchDeadline)
  $report['visible_fallback'] = $visible
  $report['icon_rectangle_after_restart'] = $hasRect

  # GetRect may have no coordinates for an active overflow icon. Reopen the
  # window if necessary, then exercise its native guard on the new Explorer.
  if (-not [MorseCQTraySmoke]::IsWindowVisible($window)) {
    if (-not [MorseCQTraySmoke]::InvokeTrayCallback($window)) { throw 'Could not deliver the tray callback to the hidden app' }
    Wait-Until { [MorseCQTraySmoke]::IsWindowVisible($window) -and -not $app.HasExited } 10 'The hidden app did not reopen after the Explorer restart'
  }
  $app.Refresh()
  if (-not $app.CloseMainWindow()) { throw 'The recovered window refused close-to-tray' }
  Wait-Until { -not [MorseCQTraySmoke]::IsWindowVisible($window) -and -not $app.HasExited } 10 'The recovered window could not hide after checking the replacement tray registration'
  $report['native_guarded_hide_after_restart'] = $true
  $report['icon_rectangle_after_hiding_again'] = [MorseCQTraySmoke]::HasIconRectangle($window)
  if (-not [MorseCQTraySmoke]::InvokeTrayCallback($window)) { throw 'Could not deliver the tray callback to the installed app' }
  Wait-Until { [MorseCQTraySmoke]::IsWindowVisible($window) -and -not $app.HasExited } 15 'The tray callback did not reopen the installed window'
  $report['tray_callback_reopened_window'] = $true
  $report.outcome = 'passed'
} catch {
  $report['error'] = $_.Exception.Message
  throw
} finally {
  try {
    if ($restartRequested -and -not (Get-TaskbarExplorer)) { Start-Process "$env:WINDIR\explorer.exe" }
    if ($app -and -not $app.HasExited) {
      Stop-Process -InputObject $app -Force
      if (-not $app.WaitForExit(10000)) { throw 'The test app did not exit during cleanup' }
    }
    if ($null -ne $savedSettings) { Set-Content -LiteralPath $SettingsPath -Value $savedSettings -NoNewline -Encoding utf8 }
    elseif (Test-Path -LiteralPath $SettingsPath) { Remove-Item -LiteralPath $SettingsPath }
  } finally {
    $report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $EvidencePath -Encoding utf8
  }
}
