@echo off
setlocal enabledelayedexpansion

REM Check if profile parameter is provided
if "%~1"=="" (
    echo Error: Profile name is required.
    echo Usage: loop.bat profile_name
    exit /b 1
)

set PROFILE=%~1
set PROFILE_DIR=miner-state\%PROFILE%
set STOP_FLAG=%PROFILE_DIR%\stop.flag
set LOG_DIR=%PROFILE_DIR%\logs

REM Create logs directory if it doesn't exist
if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
    echo Created logs directory: %LOG_DIR%
)

REM Install required packages
pip install psutil --quiet
pip install requests --quiet

REM Create a modified loop.py that checks for stop flag
echo import psutil > loop_profile.py
echo import subprocess >> loop_profile.py
echo import time >> loop_profile.py
echo import datetime >> loop_profile.py
echo import os >> loop_profile.py
echo. >> loop_profile.py
echo # Profile-specific settings >> loop_profile.py
echo profile = "%PROFILE%" >> loop_profile.py
echo profile_dir = "miner-state/%PROFILE%" >> loop_profile.py
echo stop_flag = "%STOP_FLAG%" >> loop_profile.py
echo log_dir = "%LOG_DIR%" >> loop_profile.py
echo log_file = os.path.join(log_dir, "miner_log.txt") >> loop_profile.py
echo. >> loop_profile.py
echo threshold_percentage = 50 >> loop_profile.py
echo included_processes = ['msedge.exe']  # List of process names to include >> loop_profile.py
echo. >> loop_profile.py
echo def log_cpu_usage(): >> loop_profile.py
echo     with open(log_file, "a") as f: >> loop_profile.py
echo         timestamp = datetime.datetime.now().strftime("%%Y-%%m-%%d %%H:%%M:%%S") >> loop_profile.py
echo         f.write(f"[{timestamp}] CPU Usage Log\\n") >> loop_profile.py
echo         for process in psutil.process_iter(['name', 'cpu_percent']): >> loop_profile.py
echo             process_name = process.info['name'] >> loop_profile.py
echo             cpu_percent = process.info['cpu_percent'] >> loop_profile.py
echo             if cpu_percent ^> threshold_percentage and process_name not in ['System Idle Process', 'python.exe']: >> loop_profile.py
echo                 f.write(f"{process_name} : {cpu_percent}%%\\n") >> loop_profile.py
echo. >> loop_profile.py
echo def check_stop_flag(): >> loop_profile.py
echo     """Check if the stop flag file exists.""" >> loop_profile.py
echo     if os.path.exists(stop_flag): >> loop_profile.py
echo         print(f"Stop flag detected at {stop_flag}. Exiting gracefully.") >> loop_profile.py
echo         with open(log_file, "a") as f: >> loop_profile.py
echo             timestamp = datetime.datetime.now().strftime("%%Y-%%m-%%d %%H:%%M:%%S") >> loop_profile.py
echo             f.write(f"[{timestamp}] Stop flag detected. Exiting gracefully.\\n") >> loop_profile.py
echo         return True >> loop_profile.py
echo     return False >> loop_profile.py
echo. >> loop_profile.py
echo def main(): >> loop_profile.py
echo     print(f"Starting miner loop for profile: {profile}") >> loop_profile.py
echo     print(f"Logs will be saved to: {log_file}") >> loop_profile.py
echo     print(f"Will exit if stop flag is detected at: {stop_flag}") >> loop_profile.py
echo. >> loop_profile.py
echo     # Create log directory if it doesn't exist >> loop_profile.py
echo     os.makedirs(log_dir, exist_ok=True) >> loop_profile.py
echo. >> loop_profile.py
echo     # Log startup >> loop_profile.py
echo     with open(log_file, "a") as f: >> loop_profile.py
echo         timestamp = datetime.datetime.now().strftime("%%Y-%%m-%%d %%H:%%M:%%S") >> loop_profile.py
echo         f.write(f"[{timestamp}] Miner loop started for profile: {profile}\\n") >> loop_profile.py
echo. >> loop_profile.py
echo     last_log_time = time.time() >> loop_profile.py
echo     log_interval = 60  # Log every minute >> loop_profile.py
echo. >> loop_profile.py
echo     while True: >> loop_profile.py
echo         # Check for stop flag >> loop_profile.py
echo         if check_stop_flag(): >> loop_profile.py
echo             break >> loop_profile.py
echo. >> loop_profile.py
echo         processes_exceeded_threshold = False  # Flag to track if any process exceeds the threshold >> loop_profile.py
echo         for process in psutil.process_iter(['name', 'cpu_percent']): >> loop_profile.py
echo             process_name = process.info['name'] >> loop_profile.py
echo             cpu_percent = process.info['cpu_percent'] >> loop_profile.py
echo             if process_name != 'Idle' and process_name in included_processes: >> loop_profile.py
echo                 print(f"Process to be terminated: {process_name} (CPU Usage: {cpu_percent}%%)") >> loop_profile.py
echo                 try: >> loop_profile.py
echo                     subprocess.run(['taskkill', '/F', '/IM', process_name], check=True) >> loop_profile.py
echo                     print(f"Terminated process: {process_name}") >> loop_profile.py
echo                 except subprocess.CalledProcessError: >> loop_profile.py
echo                     print(f"Failed to terminate process: {process_name}") >> loop_profile.py
echo. >> loop_profile.py
echo             if cpu_percent ^> threshold_percentage: >> loop_profile.py
echo                 processes_exceeded_threshold = True >> loop_profile.py
echo. >> loop_profile.py
echo         current_time = time.time() >> loop_profile.py
echo         if (current_time - last_log_time) ^>= log_interval: >> loop_profile.py
echo             log_cpu_usage() >> loop_profile.py
echo             last_log_time = current_time >> loop_profile.py
echo. >> loop_profile.py
echo         time.sleep(10)  # Check every 10 seconds >> loop_profile.py
echo. >> loop_profile.py
echo     print("Miner loop exited gracefully") >> loop_profile.py
echo. >> loop_profile.py
echo if __name__ == "__main__": >> loop_profile.py
echo     main() >> loop_profile.py

REM Run the profile-specific loop script
python loop_profile.py

REM Clean up
del loop_profile.py

echo Miner loop for profile %PROFILE% has ended.