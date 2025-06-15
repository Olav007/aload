Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableCloudClipboard" -Value 1 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "CloudClipboardSyncSetting" -Value 1 -Type DWord
git config --global --add safe.directory D:/aload
git config --global user.email "aload@orgt.eu"
git config --global user.name "Aload Aload"
w32tm /resync