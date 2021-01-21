$srcFolder = "C:\GitLab-Runner"

[environment]::SetEnvironmentVariable("RUNNER_SRC", $srcFolder, "Machine")

Write-Host "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install --force -y git -params /GitAndUnixToolsOnPath
choco install -y git-lfs powershell-core cygwin gitlab-runner
