$ErrorActionPreference = 'Stop'
$installer = "$env:TEMP\CloudbaseInitSetup.msi"
Invoke-WebRequest -Uri "https://www.cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi" -OutFile $installer
Start-Process msiexec.exe -ArgumentList "/i $installer /qn /norestart" -Wait
