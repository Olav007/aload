# 1) Enable the lightweight Hyper-V back-end
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All

# 2) Enable the core WSL driver
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All

# 3) Reboot to finalize both features
#Restart-Computer
