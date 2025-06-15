dir$env:DADIR = $DADIR ?? 'D:\a'
$env:SCOOP = "$env:DADIR\scoop"
$env:PATH = "$env:SCOOP\shims;$env:PATH"