@echo off
setlocal enabledelayedexpansion

:: Configuration
:: Store layouts and logs in %APPDATA%\DesktopLayoutManager
set "BASE_DIR=%APPDATA%\DesktopLayoutManager"
set "BACKUP_DIR=%BASE_DIR%\Layouts"
set "LOG_FILE=%BASE_DIR%\desktop_layout.log"
set "REG_KEY=HKCU\Software\Microsoft\Windows\Shell\Bags\1\Desktop"

:: Create directories if they don't exist
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%" >nul 2>&1
)

:: Instructions and menu
:MENU
cls
echo ============================================
echo         Desktop Layout Manager
echo ============================================
echo A tool to save and restore your desktop icon
echo layout configurations easily.
echo.
echo 1) Save Layout
echo 2) Restore Layout
echo 3) Exit
echo.
echo NOTE: Layouts and logs are stored in:
echo %BACKUP_DIR%
echo (This location is hidden in %APPDATA%, but accessible if needed.)
echo.
choice /c 123 /m "Enter choice:"
if errorlevel 3 goto exit
if errorlevel 2 goto restore
if errorlevel 1 goto save

:save
cls
echo =========================
echo       Save Layout
echo =========================
echo Enter a name for this layout (e.g., Work, Gaming, Clean):
set /p LAYOUT_NAME="Name: "
if "%LAYOUT_NAME%"=="" (
    set "LAYOUT_NAME=default"
)

:: Generate a timestamp for the filename: YYYY-MM-DD_HH-MM
set "timestamp=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%"
set "REG_FILE=%BACKUP_DIR%\desktop_layout_%LAYOUT_NAME%_%timestamp%.reg"

echo Saving current desktop layout...
reg export "%REG_KEY%" "%REG_FILE%" /y >nul 2>&1

if exist "%REG_FILE%" (
    echo Layout saved as:
    echo %REG_FILE%
    echo.
    echo Writing to log...
    echo [%date% %time%] SAVED: %REG_FILE% >> "%LOG_FILE%"
    echo Successfully saved layout.
) else (
    echo Failed to save layout.
    echo [%date% %time%] ERROR: Failed to save layout "%LAYOUT_NAME%" >> "%LOG_FILE%"
)
echo.
pause
goto MENU

:restore
cls
echo =========================
echo       Restore Layout
echo =========================
echo Available layouts:
echo (Press Ctrl+C to abort at any time)
echo.

:: List available .reg files
dir "%BACKUP_DIR%\desktop_layout_*.reg" /b 2>nul
if errorlevel 1 (
    echo No saved layouts found.
    echo.
    pause
    goto MENU
)

echo.
echo Enter the exact filename of the layout to restore (include .reg):
set /p REG_CHOICE="Filename: "

if "%REG_CHOICE%"=="" (
    echo No filename entered.
    pause
    goto MENU
)

if not exist "%BACKUP_DIR%\%REG_CHOICE%" (
    echo File not found: %REG_CHOICE%
    pause
    goto MENU
)

echo Restoring layout from %REG_CHOICE%...
reg import "%BACKUP_DIR%\%REG_CHOICE%" >nul 2>&1
if errorlevel 1 (
    echo Registry import failed. Layout not restored.
    echo [%date% %time%] ERROR: Failed to restore %REG_CHOICE% >> "%LOG_FILE%"
    pause
    goto MENU
)

:: Restart Explorer to apply
taskkill /F /IM explorer.exe >nul 2>&1
start explorer.exe

echo Layout restored successfully!
echo [%date% %time%] RESTORED: %REG_CHOICE% >> "%LOG_FILE%"
echo.
echo Note: If the screen resolution or monitor setup changed since saving, the layout may not appear as expected.
pause
goto MENU

:exit
echo Exiting...
endlocal