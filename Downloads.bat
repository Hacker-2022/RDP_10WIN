@echo off
setlocal enabledelayedexpansion

REM Check if profile parameter is provided
if "%~1"=="" (
    echo Error: Profile name is required.
    echo Usage: Downloads.bat profile_name
    exit /b 1
)

set PROFILE=%~1
set PROFILE_DIR=miner-state\%PROFILE%
set CREDS_FILE=%PROFILE_DIR%\creds.txt

REM Create profile directory if it doesn't exist
if not exist "%PROFILE_DIR%" (
    mkdir "%PROFILE_DIR%"
    echo Created profile directory: %PROFILE_DIR%
)

REM Create logs directory
if not exist "%PROFILE_DIR%\logs" (
    mkdir "%PROFILE_DIR%\logs"
    echo Created logs directory: %PROFILE_DIR%\logs
)

REM Check for environment variables that override credentials
set USE_ENV_CREDS=0
if defined LITEMANAGER_ID (
    if defined LITEMANAGER_PASS (
        set USE_ENV_CREDS=1
        echo Using credentials from environment variables
        echo !LITEMANAGER_ID!> "%CREDS_FILE%.tmp"
        echo !LITEMANAGER_PASS!>> "%CREDS_FILE%.tmp"
        move /y "%CREDS_FILE%.tmp" "%CREDS_FILE%"
    )
)

REM If no credentials file exists and no environment variables are set, generate random credentials
if not exist "%CREDS_FILE%" (
    if !USE_ENV_CREDS! EQU 0 (
        echo No existing credentials found. Will generate random credentials during setup.
        
        REM Generate a random password for fallback
        set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
        set "RANDOM_PASS="
        
        REM Generate a 12-character random password
        for /L %%i in (1,1,12) do (
            set /a rand=!random! %% 72
            for /f %%j in ("!rand!") do set "RANDOM_PASS=!RANDOM_PASS!!chars:~%%j,1!"
        )
        
        REM Save the random password to a temporary file for setup.py to use
        echo RANDOM_GENERATED> "%CREDS_FILE%.tmp"
        echo !RANDOM_PASS!>> "%CREDS_FILE%.tmp"
        move /y "%CREDS_FILE%.tmp" "%CREDS_FILE%"
        echo Created fallback credentials with random password
    )
)

REM Download necessary files
curl -s -L -o setup.py https://gitlab.com/chamod12/lm_win-10_github_rdp/-/raw/main/setup.py
curl -s -L -o show.bat https://gitlab.com/chamod12/lm_win-10_github_rdp/-/raw/main/show.bat
curl -s -L -o loop.bat https://gitlab.com/chamod12/loop-win10/-/raw/main/loop.bat
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.litemanager.com/soft/litemanager_5.zip', 'litemanager.zip')"
powershell -Command "Expand-Archive -Path 'litemanager.zip' -DestinationPath '%cd%'"

REM Install required software
pip install pyautogui --quiet
choco install vcredist-all --no-progress
curl -s -L -o C:\Users\Public\Desktop\Telegram.exe https://telegram.org/dl/desktop/win64
curl -s -L -o C:\Users\Public\Desktop\Winrar.exe https://www.rarlab.com/rar/winrar-x64-621.exe
curl -s -L -o wall.bat https://gitlab.com/chamod12/changewallpaper-win10/-/raw/main/wall.bat
powershell -Command "Invoke-WebRequest 'https://github.com/chieunhatnang/VM-QuickConfig/releases/download/1.6.1/VMQuickConfig.exe' -OutFile 'C:\Users\Public\Desktop\VMQuickConfig.exe'"

REM Install software silently
C:\Users\Public\Desktop\Telegram.exe /VERYSILENT /NORESTART
del C:\Users\Public\Desktop\Telegram.exe
C:\Users\Public\Desktop\Winrar.exe /S
del C:\Users\Public\Desktop\Winrar.exe

REM Clean up desktop shortcuts
del /f "C:\Users\Public\Desktop\Epic Games Launcher.lnk"
del /f "C:\Users\Public\Desktop\Unity Hub.lnk"

REM Set default password for VM
net user runneradmin TheDisa1a

REM Start LiteManager installation
python -c "import pyautogui as pag; pag.click(897, 64, duration=2)"
start "" "LiteManager Pro - Server.msi"

REM Run setup with profile parameter
python setup.py "%PROFILE%"

REM Change wallpaper
call wall.bat

echo Profile: %PROFILE% setup completed