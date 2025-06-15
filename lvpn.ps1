# 1. Use SCOOP env var if set, otherwise default to your SSD path
$SCOOP = $env:SCOOP
if (-not $SCOOP) {
    $SCOOP = "D:\a\scoop"
    Write-Output "INFO: SCOOP not set, defaulting to $SCOOP"
} else {
    Write-Output "INFO: Using SCOOP from environment: $SCOOP"
}

# 2. Define app paths
$vpnPath = Join-Path $SCOOP "apps\mullvadvpn-np\current\Mullvad VPN.exe"
$browserPath = Join-Path $SCOOP "apps\mullvad-browser\current\mullvadbrowser.exe"

# 3. Launch Mullvad VPN if not already running
if (-not (Get-Process -Name "Mullvad VPN" -ErrorAction SilentlyContinue)) {
    Write-Output "Launching Mullvad VPN..."
    Start-Process -FilePath $vpnPath
    Start-Sleep -Seconds 8
} else {
    Write-Output "Mullvad VPN is already running."
}

# 4. Optional: Check VPN connection status
$mullvadCli = "C:\Program Files\Mullvad VPN\resources\mullvad-daemon\mullvad.exe"
if (Test-Path $mullvadCli) {
    $vpnStatus = & $mullvadCli status 2>$null
    if ($vpnStatus -like "*Connected*") {
        Write-Output "VPN is connected: $vpnStatus"
    } else {
        Write-Output "VPN not connected yet - connect manually if needed."
    }
} else {
    Write-Output "Note: Mullvad CLI not found. Skipping VPN status check."
}

# 5. Launch Mullvad Browser
Write-Output "Launching Mullvad Browser..."
Start-Process -FilePath $browserPath
