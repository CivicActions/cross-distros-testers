$srcFolder = "C:\GitLab-Runner"

[environment]::SetEnvironmentVariable("RUNNER_SRC", $srcFolder, "Machine")

Write-Host "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install git -y
choco install git-lfs -y
choco install powershell-core -y
choco install cygwin -y
choco install gitlab-runner -y
