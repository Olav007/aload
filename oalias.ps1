Set-Alias -Name owarp -Value "$env:SCOOP\apps\warp-terminal\current\warp.exe"
# Define the oaddb function to add specified directories to the PATH
function oaddb {
    $dirs = @(
        "D:\a\scoop\apps\git-with-openssh",
        "D:\a\scoop\apps\git"
    )
    
    foreach ($dir in $dirs) {
        # Check if the directory exists
        if (Test-Path -Path $dir) {
            # Check if the directory is already in the PATH to avoid duplicates
            if ($env:Path -notlike "*$dir*") {
                $env:Path += ";$dir"
                Write-Output "Added $dir to PATH."
            } else {
                Write-Output "$dir is already in PATH."
            }
        } else {
            Write-Output "Directory $dir does not exist."
        }
    }
}