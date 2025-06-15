# ================================
# 🔐 Mullvad VPN + Browser Launcher
# ================================

Write-Host "`n=============================" -ForegroundColor Cyan
Write-Host "🔎 Mullvad Diagnostic Info" -ForegroundColor Green
Write-Host "=============================`n" -ForegroundColor Cyan

# --- Section 1: Scoop Path Detection ---
$SCOOP = $env:SCOOP
if (-not $SCOOP) {
    $SCOOP = "D:\a\scoop"
    Write-Host "INFO: SCOOP not set, defaulting to $SCOOP"
} else {
    Write-Host "INFO: Using SCOOP from environment: $SCOOP"
}

# --- Section 2: Mullvad Executable Paths ---
$vpnPathCDrive = "C:\Program Files\Mullvad VPN\Mullvad VPN.exe"
$scoopFallbackVpn = Get-ChildItem -Path (Join-Path $SCOOP "apps\mullvadvpn-np\current") -Filter "Mullvad VPN.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

if (Test-Path $vpnPathCDrive) {
    $vpnPath = $vpnPathCDrive
    Write-Host "✅ Found Mullvad VPN on C: drive"
} elseif ($scoopFallbackVpn) {
    $vpnPath = $scoopFallbackVpn
    Write-Host "🔄 Using Mullvad VPN from Scoop"
} else {
    Write-Host "❌ Mullvad VPN not found. Cannot proceed." -ForegroundColor Red
    exit 1
}

# Browser path (always via Scoop)
$browserPath = Join-Path $SCOOP "apps\mullvad-browser\current\mullvadbrowser.exe"
if (-not (Test-Path $browserPath)) {
    Write-Host "❌ Mullvad Browser not found. Cannot launch browser." -ForegroundColor Red
    exit 1
}

# --- Section 3: Start Mullvad VPN ---
if (-not (Get-Process -Name "Mullvad VPN" -ErrorAction SilentlyContinue)) {
    Write-Host "🟢 Launching Mullvad VPN..."
    Start-Process -FilePath $vpnPath
    Start-Sleep -Seconds 5
} else {
    Write-Host "ℹ️ Mullvad VPN already running."
}

# --- Section 4: Optional: Auto-connect to Norway ---
$mullvadCli = "C:\Program Files\Mullvad VPN\resources\mullvad-daemon\mullvad.exe"
if (Test-Path $mullvadCli) {
    Write-Host "🌍 Setting Mullvad exit server to Norway..."
    & $mullvadCli relay set location no
    & $mullvadCli connect
} else {
    Write-Host "⚠️ CLI not found. Skipping auto-connect."
}

# --- Section 5: Wait for VPN to Connect ---
$maxWait = 30
$elapsed = 0
$connected = $false

if (Test-Path $mullvadCli) {
    while ($elapsed -lt $maxWait) {
        $status = & $mullvadCli status
        if ($status -like "*Connected*") {
            Write-Host "✅ VPN connected: $status"
            $connected = $true
            break
        }
        Start-Sleep -Seconds 1
        $elapsed++
    }
} else {
    Write-Host "⏩ Skipping status check — no CLI"
    $connected = $true  # Assume OK for portable use
}

if (-not $connected) {
    Write-Host "❌ VPN did not connect within $maxWait seconds." -ForegroundColor Red
    exit 1
}

# --- Section 6: Launch Browser ---
Write-Host "🚀 Launching Mullvad Browser..."
Start-Process -FilePath $browserPath
