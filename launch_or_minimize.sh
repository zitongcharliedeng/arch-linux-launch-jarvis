#!/bin/bash

# --- SCRIPT DESCRIPTION ---
# This script toggles a specified application between fullscreen and minimized states.
#
# - If the application is NOT running: It launches the application in fullscreen mode.
# - If the application IS running and NOT fullscreen:  It makes the application fullscreen and focuses it.
# - If the application IS running and IS fullscreen: It minimizes (hides) the application.
#
# It uses wmctrl to interact with the window manager so make sure you install this dependency among the others.
#
# --- CONFIGURATION ---
# 1.  Replace "plasma-discover" with the actual command to launch your application.
application_command="plasma-discover"

# 2.  Replace "Discover" with a string that *uniquely* identifies the application's window title.
window_title_match="Discover"

# --- DEBUGGING ---
# Enable debugging output (set to 1 to enable, 0 to disable)
DEBUG=1

# Function to log messages to a new Konsole window
log_to_konsole() {
  if [ "$DEBUG" -eq 1 ]; then
    konsole --hold -e bash -c "echo '$1'; read -n 1 -s -r -p 'Press any key to close...'" &
  fi
}

# --- SCRIPT LOGIC ---

log_to_konsole "Starting script..."

window_id=$(wmctrl -l | grep "$window_title_match" | awk '{print $1}' | head -n 1)

if [ -n "$window_id" ]; then
    log_to_konsole "Window found. Window ID: $window_id"
    state=$(wmctrl -lG | grep "$window_title_match" | awk '{print $10}')
    log_to_konsole "Window state: $state"
    if [[ "$state" == *"fullscreen"* ]]; then
      log_to_konsole "Window is fullscreen, minimizing..."
      wmctrl -i -r "$window_id" -b add,hidden
    else
      log_to_konsole "Window is NOT fullscreen, making it fullscreen and focusing..."
      wmctrl -i -r "$window_id" -b add,fullscreen
      wmctrl -i -a "$window_id"
    fi
else
  log_to_konsole "Window not found, launching application..."
  $application_command &
  sleep 0.5
  new_window_id=$(wmctrl -l | grep "$window_title_match" | awk '{print $1}' | tail -n 1)

    if [ -n "$new_window_id" ]; then
        log_to_konsole "New window ID after launch: $new_window_id"
        wmctrl -i -r "$new_window_id" -b add,fullscreen
    else
        log_to_konsole "ERROR: Could not find new window ID after launch."
    fi
fi

log_to_konsole "Script finished."

exit 0
