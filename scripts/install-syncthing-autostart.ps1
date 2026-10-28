$taskName = 'Wizard Sync Syncthing'
$userName = "$env:USERDOMAIN\$env:USERNAME"
$syncthingExe = Join-Path $env:LOCALAPPDATA 'Programs\Syncthing\syncthing.exe'
$homeDir = Join-Path $env:LOCALAPPDATA 'Syncthing'

if (!(Test-Path $syncthingExe)) {
  throw "Syncthing executable not found: $syncthingExe"
}

$psCommand = @"
Start-Sleep -Seconds 8
if (-not (Get-Process syncthing -ErrorAction SilentlyContinue)) {
  Start-Process -FilePath '$syncthingExe' -ArgumentList 'serve','--no-browser','--home=$homeDir' -WindowStyle Hidden
}
"@

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `$ErrorActionPreference='Stop'; $psCommand"
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $userName
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
$principal = New-ScheduledTaskPrincipal -UserId $userName -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Starts Syncthing for Wizard Sync at Windows logon.' -Force | Out-Null

Get-ScheduledTask -TaskName $taskName | Format-List TaskName,State,Description
