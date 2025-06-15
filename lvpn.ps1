# This script ensures Mullvad VPN is running and connected, then launches the Mullbad Browser.

# --- Configuration & Pre-checks ---

# 1. Use the official SCOOP environment variable. Exit if it's not set.
if (-not $env:SCOOP) {
    Write-Error "Error: The SCOOP environment variable was not found. Please ensure Scoop is installed correctly."
    # Pause to allow the user to read the error before the window closes.
    if ($Host.Name -eq "ConsoleHost") { Start-Sleep -Seconds 10 }
    exit 1
}
Write-Output "INFO: Using SCOOP from environment: $env:SCOOP"

# 2. Define application paths dynamically from the Scoop directory.
$vpnAppPath = Join-Path $env:SCOOP "apps\mullvadvpn-np\current\Mullvad VPN.exe"
$browserAppPath = Join-Path $env:SCOOP "apps\mullvad-browser\current\mullvadbrowser.exe"
# The CLI tool is located relative to the main VPN executable. This is more reliable than a hardcoded path.
$mullvadCliPath = Join-Path (Split-Path $vpnAppPath -Parent) "resources\mullvad-daemon\mullvad.exe"

# 3. Verify that the required applications actually exist before proceeding.
if (-not (Test-Path -LiteralPath $vpnAppPath)) {
    Write-Error "Error: Mullvad VPN not found at expected path: $vpnAppPath"
    if ($Host.Name -eq "ConsoleHost") { Start-Sleep -Seconds 10 }
    exit 1
}
if (-not (Test-Path -LiteralPath $browserAppPath)) {
    Write-Error "Error: Mullvad Browser not found at expected path: $browserAppPath"
    if ($Host.Name -eq "ConsoleHost") { Start-Sleep -Seconds 10 }
    exit 1
}

# --- Execution ---

# 4. Launch Mullvad VPN if its process isn't already running.
# Note: The process name is often just "Mullvad VPN" without the .exe
if (-not (Get-Process -Name "Mullvad VPN" -ErrorAction SilentlyContinue)) {
    Write-Output "INFO: Mullvad VPN is not running. Launching now..."
    Start-Process -FilePath $vpnAppPath
    Write-Output "INFO: Waiting for 8 seconds for the VPN service to initialize..."
    Start-Sleep -Seconds 8
} else {
    Write-Output "INFO: Mullvad VPN is already running."
}

# 5. Check VPN connection status using the CLI tool.
if (Test-Path -LiteralPath $mullvadCliPath) {
    Write-Output "INFO: Checking VPN connection status..."
    $vpnStatus = & $mullvadCliPath status --wait 2>$null
    if ($vpnStatus -like "*Connected to*") {
        # Extract the server info for a more detailed message.
        $serverInfo = $vpnStatus -replace '.*Connected to (.*) in.*', '$1'
        Write-Host -ForegroundColor Green "✅ VPN is connected to $serverInfo."
    } else {
        Write-Warning "⚠️ WARNING: VPN is not connected. Please connect manually in the app before browsing."
    }
} else {
    Write-Warning "NOTE: Could not find Mullvad CLI tool. Skipping VPN status check."
}

# 6. Launch Mullvad Browser.
Write-Output "INFO: Launching Mullvad Browser..."
Start-Process -FilePath $browserAppPath

Write-Host -ForegroundColor Cyan "Script finished."
