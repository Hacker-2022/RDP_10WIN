@echo off
setlocal enabledelayedexpansion

REM Check if profile parameter is provided
if "%~1"=="" (
    echo Error: Profile name is required.
    echo Usage: show.bat profile_name
    exit /b 1
)

set PROFILE=%~1
set PROFILE_DIR=miner-state\%PROFILE%
set CREDS_FILE=%PROFILE_DIR%\creds.txt

REM Check if credentials file exists
if not exist "%CREDS_FILE%" (
    echo Error: Credentials file not found for profile %PROFILE%
    echo Please run Downloads.bat %PROFILE% first to set up credentials.
    exit /b 1
)

REM Read credentials from file
for /f "tokens=*" %%a in ('type "%CREDS_FILE%"') do (
    if not defined LM_ID (
        set LM_ID=%%a
    ) else if not defined LM_PASS (
        set LM_PASS=%%a
    )
)

REM Start VMQuickConfig
start "" /MAX "C:\Users\Public\Desktop\VMQuickConfig"
python -c "import pyautogui as pag; pag.click(143, 487, duration=5)"
python -c "import pyautogui as pag; pag.click(155, 554, duration=2)"
python -c "import pyautogui as pag; pag.click(637, 417, duration=2)"
python -c "import pyautogui as pag; pag.click(588, 10, duration=2)"

echo ..........................................................
echo .....Brought By KADDU © 2025.............................
echo ..........................................................
echo ......#####...######...####....####...##.......####.......
echo ......##..##....##....##......##..##..##......##..##......
echo ......##..##....##.....####...######..##......######......
echo ......##..##....##........##..##..##..##......##..##......
echo ......#####...######...####...##..##..######..##..##......
echo ..........................................................
echo ......... All Rights Reserved ............................
echo ..........................................................
echo ..........................................................
echo Profile: %PROFILE%
echo User name: runneradmin
echo User Pass: TheDisa1a
echo LiteManager ID: %LM_ID%
echo LiteManager Password: %LM_PASS%