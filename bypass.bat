@echo off
chcp 65001 >nul
title Bypass Integrity Check
 
:: config
set "APPDIR=%LOCALAPPDATA%\MAT"
set "EXE=%APPDIR%\MAT.exe"
set "LAUNCHER_VBS=%APPDIR%\run_mat_launcher.vbs"
set "REGNAME=MATLauncher"
 
:menu
cls
echo ================================
echo     Bypass Integrity Check
echo ================================
echo.
echo 1. Enable
echo 2. Disable
echo 0. Exit
echo.
set /p choice=Choose : 
 
if "%choice%"=="1" goto create_start
if "%choice%"=="2" goto stop_remove
if "%choice%"=="0" goto end
goto menu
 
:create_start
echo.
if not exist "%APPDIR%" mkdir "%APPDIR%" 2>nul
 
if exist "%EXE%" (
    echo File already exists. Will not overwrite.
) else (
    copy /y "%SystemRoot%\System32\cmd.exe" "%EXE%" >nul 2>&1
    if errorlevel 1 (
        echo Copy failed. Maybe restricted; try running this script from a different location.
        pause
        goto menu
    )
 
)
 
:: create a small VBS that runs MAT.exe hidden with a low-CPU loop
> "%LAUNCHER_VBS%" echo Set WshShell = CreateObject("WScript.Shell")
>> "%LAUNCHER_VBS%" echo exe = "%EXE%"
>> "%LAUNCHER_VBS%" echo args = " /k for /L %%I in (0,1,1) do (ping -n 60 127.0.0.1 ^>nul)"
>> "%LAUNCHER_VBS%" echo WshShell.Run Chr(34) ^& exe ^& Chr(34) ^& args, 0, False
 
if not exist "%LAUNCHER_VBS%" (
    echo Failed to create VBS launcher: %LAUNCHER_VBS%.
	echo.
    pause
    goto menu
)
 
:: add to HKCU Run so it starts at login (no admin required)
echo Adding registry Run entry for current user...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%REGNAME%" /d "wscript.exe \"%LAUNCHER_VBS%\"" /f >nul 2>&1
if errorlevel 1 (
    echo Failed to add registry Run entry.
) else (
    echo Registry Run entry added.
)
 
wscript "%LAUNCHER_VBS%" 2>nul
 
echo.
pause
goto menu
 
:stop_remove
echo.
echo Removing registry Run entry...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "%REGNAME%" /f >nul 2>&1
 
taskkill /F /IM MAT.exe >nul 2>&1
 
echo Deleting files
if exist "%APPDIR%" rd /s /q "%APPDIR%" >nul 2>&1
 
echo Done.
echo.
pause
goto menu
 
:end
echo Bye.
exit /b 0