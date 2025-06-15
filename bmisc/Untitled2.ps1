# --- CONFIGURATION ---
$isoPath  = 'D:\w\Win11_24H2_English_x64.iso'
$wimIndex = 6           # Pro = 6; change if you’re on another edition
$mountDir = 'C:\WinMount'
# ----------------------

# 1) Mount the ISO
Write-Host "Mounting ISO $isoPath…" -ForegroundColor Cyan
Mount-DiskImage -ImagePath $isoPath

# 2) Grab its drive letter (e.g. E:)
$dvd = (Get-DiskImage -ImagePath $isoPath | Get-Volume).DriveLetter + ':'
Write-Host "ISO is mounted at $dvd" -ForegroundColor Green

# 3) Prepare WinSxS mount folder
if (Test-Path $mountDir) {
    Write-Host "Cleaning up previous mount…" -ForegroundColor Yellow
    dism.exe /Unmount-Wim /MountDir:$mountDir /Discard 2>$null
    Remove-Item -LiteralPath $mountDir -Recurse -Force
}
New-Item -Path $mountDir -ItemType Directory | Out-Null

# 4) Mount the Pro image (Index $wimIndex) read-only
$wimPath = "$dvd\sources\install.wim"
Write-Host "Mounting $wimPath (Index $wimIndex) → $mountDir…" -ForegroundColor Cyan
dism.exe /Mount-Wim /WimFile:$wimPath /Index:$wimIndex /MountDir:$mountDir /ReadOnly

# 5) Enable VirtualMachinePlatform from that WinSxS
Write-Host "Enabling VirtualMachinePlatform…" -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online `
  -FeatureName VirtualMachinePlatform -All `
  -Source "$mountDir\Windows\winsxs" -LimitAccess

# 6) Enable the WSL core feature
Write-Host "Enabling Windows Subsystem for Linux…" -ForegroundColor Cyan
Enable-WindowsOptionalFeature -Online `
  -FeatureName Microsoft-Windows-Subsystem-Linux -All

# 7) Unmount & dismount everything
Write-Host "Cleaning up mounts…" -ForegroundColor Cyan
dism.exe /Unmount-Wim /MountDir:$mountDir /Discard
Dismount-DiskImage -ImagePath $isoPath

# 8) Show you the result
Write-Host "`nFeature states:" -ForegroundColor Cyan
Get-WindowsOptionalFeature -Online `
  -FeatureName VirtualMachinePlatform,Microsoft-Windows-Subsystem-Linux |
  Format-Table FeatureName,State

Write-Host "`nwsl --status:" -ForegroundColor Cyan
wsl --status
