<#
.SYNOPSIS
    Gathers and displays diagnostic information about the Scoop and Mullvad setup.

.DESCRIPTION
    This script collects key information without judging its correctness. It checks:
    - Scoop installation path.
    - List of currently installed Scoop apps.
    - Existence of key Mullvad VPN and Browser files in all expected locations.
    - Current running status of the Mullvad VPN process.
    
    Note: When copying this script, be sure to copy the raw text to avoid introducing
    special characters that can cause PowerShell parsing errors.

.OUTPUTS
    Writes a structured diagnostic report to the console.
#>

# --- Script Start ---
Write-Host -ForegroundColor Cyan "================================================"
Write-Host -ForegroundColor Cyan "🔎 Mullvad Diagnostic Information Collector"
Write-Host -ForegroundColor Cyan "================================================"
Write-Host

# --- 1. Scoop Information ---
Write-Host -ForegroundColor Yellow "--- Section 1: Scoop Environment ---"
$scoopPath = $env:SCOOP
if (-not $scoopPath) {
    Write-Host "Scoop Path (`$env:SCOOP`): [Not Set]"
} else {
    Write-Host "Scoop Path (`$env:SCOOP`): $scoopPath"
    Write-Host "Scoop Apps Directory Exists: $(Test-Path (Join-Path $scoopPath 'apps'))"
    Write-Host
    Write-Host "Installed Scoop Apps:"
    Get-ChildItem (Join-Path $scoopPath 'apps') | ForEach-Object { Write-Host "  - $($_.Name)" }
}
Write-Host

# --- 2. File Path Checks ---
Write-Host -ForegroundColor Yellow "--- Section 2: File & Directory Existence ---"
# Define root locations using environment variables for robustness
$programFilesPath = $env:ProgramFiles # e.g., "C:\Program Files"

# Define all potential paths to check
$pathsToCheck = @{
    "Scoop VPN Dir (mullvadvpn-np)"       = Join-Path $scoopPath "apps\mullvadvpn-np";
    "Scoop Browser Dir (mullvad-browser)" = Join-Path $scoopPath "apps\mullvad-browser";
    "Scoop VPN Exe"                       = Join-Path $scoopPath "apps\mullvadvpn-np\current\Mullvad VPN.exe";
    "Scoop VPN CLI"                       = Join-Path $scoopPath "apps\mullvadvpn-np\current\resources\mullvad-daemon\mullvad.exe";
    "Scoop Browser Exe"                   = Join-Path $scoopPath "apps\mullvad-browser\current\mullvadbrowser.exe";
    "Default Program Files VPN Exe"       = Join-Path $programFilesPath "Mullvad VPN\Mullvad VPN.exe";
    "Default Program Files VPN CLI"       = Join-Path $programFilesPath "Mullvad VPN\resources\mullvad-daemon\mullvad.exe";
}

# Loop through and test each path
foreach ($item in $pathsToCheck.GetEnumerator()) {
    $pathExists = Test-Path -LiteralPath $item.Value
    $statusColor = if ($pathExists) { "Green" } else { "Red" }
    Write-Host ("{0,-40} : " -f $item.Name) -NoNewline
    Write-Host ("[{0}]" -f $pathExists) -ForegroundColor $statusColor
}
Write-Host

# --- 3. Process Status ---
Write-Host -ForegroundColor Yellow "--- Section 3: Running Processes ---"
$vpnProcess = Get-Process -Name "Mullvad VPN" -ErrorAction SilentlyContinue
if ($vpnProcess) {
    Write-Host "Mullvad VPN Process Status      : [Running]"
    Write-Host ("Process ID (PID)                : {0}" -f $vpnProcess.Id)
} else {
    Write-Host "Mullvad VPN Process Status      : [Not Running]"
}
Write-Host

Write-Host -ForegroundColor Cyan "================================================"
Write-Host -ForegroundColor Cyan "Report Complete."
Write-Host -ForegroundColor Cyan "================================================"
