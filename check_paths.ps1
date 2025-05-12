# 1. Load the two PATH values
$userPath    = [Environment]::GetEnvironmentVariable('Path','User')
$machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')

# 2. Show lengths and warn if >1024
"User PATH length:    $($userPath.Length) characters" 
if ($userPath.Length -gt 1024) { "⚠️ User PATH exceeds 1024 chars." }

"Machine PATH length: $($machinePath.Length) characters"
if ($machinePath.Length -gt 1024) { "⚠️ Machine PATH exceeds 1024 chars." }

# 3. Combine them for full effective PATH (like in a new session)
$fullPath = "$machinePath;$userPath"

# 4. Check each folder entry
$fullPath -split ';' | ForEach-Object {
    $p = $_.Trim()
    if (-not [string]::IsNullOrEmpty($p)) {
        if (Test-Path $p) {
            Write-Host "✔️ Exists: $p"
        }
        else {
            Write-Host "❌ Missing: $p"
        }
    }
}
