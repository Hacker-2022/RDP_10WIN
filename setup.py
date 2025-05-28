import pyautogui as pag
import time
import pyperclip
import subprocess
import sys
import os
import random
import string

# Define the coordinates and use the `actions` list
actions = [
    (610, 531, 4),  # next
    (286, 459, 4),  # Accept terms
    (610, 531, 4),  # next
    (610, 531, 4),  # next
    (610, 531, 4),  # next
    (610, 531, 4),  # install
    (387, 253, 10),  # type pass
    (387, 298, 4),  # type pass
    (564, 598, 4),  # ok
    (610, 531, 4),  # finish
    (849, 746, 10),  # open litemanager
    (522, 388, 4),  # click connect
    (460, 321, 4),  # right click (select all)
    (506, 387, 4),  # click copy
    (397, 437, 4),  # open options
    (394, 286, 4),  # click auto connect
    (510, 312, 4),  # change timeout interval
    (521, 502, 4),  # click okey
]

def generate_random_password(length=10):
    """Generate a random password with letters, digits, and special characters."""
    chars = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(random.choice(chars) for _ in range(length))

def get_or_create_credentials(profile):
    """Get existing credentials or create new ones for the profile."""
    profile_dir = f"miner-state/{profile}"
    creds_file = f"{profile_dir}/creds.txt"
    
    # Check if credentials file exists
    if os.path.exists(creds_file):
        print(f"Using existing credentials from {creds_file}")
        with open(creds_file, 'r') as f:
            lines = f.readlines()
            if len(lines) >= 2:
                lm_id = lines[0].strip()
                lm_pass = lines[1].strip()
                
                # Check if this is a placeholder for random generation
                if lm_id == "RANDOM_GENERATED":
                    print("Using randomly generated password from fallback mechanism")
                    lm_id = None  # Will be captured during setup
                    return lm_id, lm_pass
                
                return lm_id, lm_pass
    
    # If we get here, either the file doesn't exist or is invalid
    # We'll generate new credentials
    lm_pass = "TheDisa1a"  # Default password
    lm_id = None  # Will be captured during setup
    
    return lm_id, lm_pass

def save_credentials(profile, lm_id, lm_pass):
    """Save credentials to the profile's creds.txt file."""
    profile_dir = f"miner-state/{profile}"
    creds_file = f"{profile_dir}/creds.txt"
    
    # Ensure directory exists
    os.makedirs(profile_dir, exist_ok=True)
    
    # Write credentials to file
    with open(creds_file, 'w') as f:
        f.write(f"{lm_id}\n{lm_pass}")
    
    print(f"Credentials saved to {creds_file}")

def main():
    # Get profile from command line argument
    profile = "default"
    if len(sys.argv) > 1:
        profile = sys.argv[1]
    
    print(f"Setting up LiteManager for profile: {profile}")
    
    # Get or create credentials
    lm_id, password = get_or_create_credentials(profile)
    timeout = "10"
    
    # Wait for a few seconds to give time to focus on the target application
    time.sleep(10)
    
    for x, y, duration in actions:
        if (x, y, duration) == (387, 253, 10):
            pag.click(x, y, duration=duration)
            pag.typewrite(password)
        elif (x, y, duration) == (387, 298, 4):
            pag.click(x, y, duration=duration)
            pag.typewrite(password)
        elif (x, y, duration) == (460, 321, 4):
            pag.rightClick(x, y, duration=duration)
        elif (x, y, duration) == (610, 531, 4):
            pag.click(x, y, duration=duration)
            cmd = r'"C:\Program Files (x86)\LiteManager Pro - Server\ROMServer.exe" /start'
            subprocess.run(cmd, shell=True)
        elif (x, y, duration) == (510, 312, 4):
            pag.click(x, y, duration=duration)
            pag.press('backspace')  # Press backspace once
            pag.press('backspace')  # Press backspace again
            pag.typewrite(timeout)
        else:
            pag.click(x, y, duration=duration)
    
    # Get the LiteManager ID from clipboard
    lm_id = pyperclip.paste()
    
    # Save credentials
    if lm_id:
        save_credentials(profile, lm_id, password)
    
    # Update show.bat with the credentials
    with open('show.bat', 'a') as file:
        file.write(f'\necho LiteManager ID: {lm_id}')
        file.write(f'\necho LiteManager Password: {password}')
    
    print(f"Done, Login Credentials for profile {profile}:")
    print(f"LiteManager ID: {lm_id}")
    print(f"LiteManager Password: {password}")

if __name__ == "__main__":
    main()
