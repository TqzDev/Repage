@echo off
title Bypass Integrity Check
:menu
cls
echo ================================
echo     Bypass Integrity Check
echo ================================
echo.
echo 1. Create MATRepair.exe
echo 2. Delete MATRepair.exe
echo 0. Exit
echo.
set /p choice=Choose an option : 
echo.

if "%choice%"=="1" goto create
if "%choice%"=="2" goto delete
if "%choice%"=="0" exit
goto menu

:create
if exist MATRepair.exe (
    echo MATRepair.exe already exists. Nothing to do.
) else (
    echo. > MATRepair.exe
    icacls MATRepair.exe /deny "BUILTIN\Users:(F)"
    echo MATRepair.exe created
)
echo.
pause
exit
goto menu

:delete
if not exist MATRepair.exe (
    echo MATRepair.exe not found. Nothing to delete.
) else (
    echo Deleting MATRepair.exe
    takeown /f MATRepair.exe >nul 2>&1
    icacls MATRepair.exe /remove:d "BUILTIN\Users" >nul 2>&1
    icacls MATRepair.exe /grant %username%:F >nul 2>&1
    del /f /q MATRepair.exe >nul 2>&1
    if exist MATRepair.exe (
        echo Failed to delete MATRepair.exe.
    ) else (
        echo MATRepair.exe deleted successfully.
    )
)
echo.
pause
exit
goto menu
