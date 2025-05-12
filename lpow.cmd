@echo off
REM ---------------------------------------------
REM load_pwsh.cmd — ensure pwsh is present and launch it
REM Place this file in <drive>:\aload\load_pwsh.cmd
REM Scoop root is at <same drive>:\a\scoop
REM ---------------------------------------------

SETLOCAL

REM 1) Determine the drive this script is running from:
set "DADRV=%~d0\"
echo [INFO] DADRV set to %DADRV%

REM 2) Define your Scoop directory (on the same drive):
set "SCOOP=%DADRV%a\scoop"
echo [INFO] SCOOP set to %SCOOP%

REM 3) Prepend Scoop’s shims to PATH so 'scoop' and 'pwsh' become available:
set "PATH=%SCOOP%\shims;%PATH%"

REM 5) Launch PowerShell Core, passing along any arguments:
echo [INFO] Launching pwsh...
"%SCOOP%\shims\pwsh.exe"
echo [INFO] Launching pwsh...2
pwsh.exe

ENDLOCAL