@echo off
setlocal enabledelayedexpansion

REM Script to clean up old log files to prevent repository bloat
REM Usage: cleanup_logs.bat [profile_name] [max_age_days] [max_size_kb]

REM Default values
set PROFILE=%~1
if "%PROFILE%"=="" set PROFILE=all
set MAX_AGE_DAYS=%~2
if "%MAX_AGE_DAYS%"=="" set MAX_AGE_DAYS=7
set MAX_SIZE_KB=%~3
if "%MAX_SIZE_KB%"=="" set MAX_SIZE_KB=1024

echo Log Cleanup Utility
echo -------------------
echo Profile: %PROFILE%
echo Max Age: %MAX_AGE_DAYS% days
echo Max Size: %MAX_SIZE_KB% KB
echo.

REM Clean up logs based on age
if "%PROFILE%"=="all" (
    echo Cleaning up logs older than %MAX_AGE_DAYS% days in all profiles...
    forfiles /P "miner-state" /S /M "*.log" /D -%MAX_AGE_DAYS% /C "cmd /c echo Deleting @path && del @path" 2>nul
    forfiles /P "miner-state" /S /M "miner_log.txt" /D -%MAX_AGE_DAYS% /C "cmd /c echo Deleting @path && del @path" 2>nul
) else (
    echo Cleaning up logs older than %MAX_AGE_DAYS% days in profile %PROFILE%...
    forfiles /P "miner-state\%PROFILE%\logs" /M "*.log" /D -%MAX_AGE_DAYS% /C "cmd /c echo Deleting @path && del @path" 2>nul
    forfiles /P "miner-state\%PROFILE%\logs" /M "miner_log.txt" /D -%MAX_AGE_DAYS% /C "cmd /c echo Deleting @path && del @path" 2>nul
)

REM Clean up logs based on size
if "%PROFILE%"=="all" (
    echo Cleaning up logs larger than %MAX_SIZE_KB% KB in all profiles...
    for /R "miner-state" %%F in (*.log *.txt) do (
        if not "%%~nxF"=="creds.txt" (
            set "file_size=%%~zF"
            set /a "file_size_kb=!file_size! / 1024"
            if !file_size_kb! GTR %MAX_SIZE_KB% (
                echo Deleting large file: %%F ^(!file_size_kb! KB^)
                del "%%F"
            )
        )
    )
) else (
    echo Cleaning up logs larger than %MAX_SIZE_KB% KB in profile %PROFILE%...
    for /R "miner-state\%PROFILE%\logs" %%F in (*.log *.txt) do (
        set "file_size=%%~zF"
        set /a "file_size_kb=!file_size! / 1024"
        if !file_size_kb! GTR %MAX_SIZE_KB% (
            echo Deleting large file: %%F ^(!file_size_kb! KB^)
            del "%%F"
        )
    )
)

echo Log cleanup completed.