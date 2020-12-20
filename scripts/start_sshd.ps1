# Set services to start automatically on boot.
Set-Service sshd -StartupType Automatic

# Start the services for the first time.
Start-Service sshd
