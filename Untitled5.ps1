# 1) Mount the ISO (adjust path if yours differs)
$isoPath = 'D:\w\Win11_24H2_English_x64.iso'
Mount-DiskImage -ImagePath $isoPath

# 2) Find its drive letter
$dvd = (Get-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter + ':'

# 3) Prepare a mount folder
$mountDir = 'C:\WinMount'
if (Test-Path $mountDir) {
  dism.exe /Unmount-Wim /MountDir:$mountDir /Discard 2>$null
  Remove-Item $mountDir -Recurse -Force
}
New-Item -ItemType Directory -Path $mountDir | Out-Null

# 4) Mount Index 1 (Home) read-only
dism.exe /Mount-Wim /WimFile:"$dvd\sources\install.wim" /Index:1 /MountDir:$mountDir /ReadOnly

# 5) Enable VirtualMachinePlatform from that Home image
dism.exe /Online /Enable-Feature /FeatureName:VirtualMachinePlatform /All `
  /Source:"$mountDir\Windows\winsxs" /LimitAccess

# 6) Enable WSL core
dism.exe /Online /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux /All

# 7) Clean up mounts
dism.exe /Unmount-Wim /MountDir:$mountDir /Discard
Dismount-DiskImage -ImagePath $isoPath

# 8) Verify
Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform |
  Format-Table FeatureName,State
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux |
  Format-Table FeatureName,State
wsl --status
