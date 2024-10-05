#!/bin/bash

# Set the initial text file, truncation lines, and default directory
text_file=""
truncate_lines=1
default_dir="$HOME"

# Directories for results, archives, and config
script_dir="$PWD"
results_dir="$script_dir/results"
archives_dir="$script_dir/archives"
config_file="$script_dir/config/config.sh"
mkdir -p "$results_dir" "$archives_dir" "$(dirname "$config_file")"

# Load the configuration file
if [ -f "$config_file" ]; then
    source "$config_file"
    text_file="${last_text_file:-$text_file}"
    truncate_lines="${last_truncate_lines:-$truncate_lines}"
    default_dir=$(dirname "$text_file")
fi

# Function to get user input for the text file
get_text_file() {
    while true; do
        text_file=$(zenity --file-selection --title="Select Text File" --filename="$default_dir" --file-filter="Text files | *.txt" --style="background-color:#282A36;color:#F8F8F2;font-size:14px")
        if [ "$?" -eq 1 ]; then
            # User clicked the "Cancel" button or closed the window
            notify_user "Canceled" "No text file selected."
            return
        elif [ ! -f "$text_file" ]; then
            notify_user "Error" "The selected file does not exist or is not a regular file."
        elif [ ! -r "$text_file" ]; then
            notify_user "Error" "You do not have permission to read the selected file."
        else
            echo "Using text file: $text_file"
            default_dir=$(dirname "$text_file")
            break
        fi
    done
}

# Function to get user input for the truncation lines
get_truncate_lines() {
    while true; do
        truncate_lines=$(zenity --entry --title="Truncate Lines" --text="Please enter the number of lines to truncate from the tail:" --ok-label="Enter" --cancel-label="-- " --extra-button="X" --style="background-color:#282A36;color:#F8F8F2;font-size:14px")
        if [ "$?" -eq 1 ]; then
            # User clicked the "Cancel" button or closed the window
            notify_user "Canceled" "No truncation value specified."
            return
        elif [ "$?" -eq 2 ]; then
            # User clicked the "X" button
            exit 0
        elif ! [[ "$truncate_lines" =~ ^[0-9]+$ ]]; then
            notify_user "Error" "Invalid truncation value. Please enter a positive integer."
        elif [ "$truncate_lines" -le 0 ]; then
            notify_user "Error" "The truncation value must be greater than 0."
        else
            # Ensure the truncation value does not exceed the number of lines in the file
            local total_lines=$(wc -l < "$text_file")
            if [ "$truncate_lines" -gt "$total_lines" ]; then
                truncate_lines=$total_lines
                notify_user "Warning" "The truncation value exceeds the number of lines in the file. Truncating to the last $truncate_lines line(s)."
            fi
            echo "Truncating $truncate_lines lines from the tail."
            break
        fi
    done
}

# Function to display a notification
notify_user() {
    local title="$1"
    local message="$2"
    notify-send --urgency=low --icon=dialog-information --expire-time=3000 --style="background-color:#282A36;color:#F8F8F2;font-size:14px" "$title" "$message"
}

# Function to clear the input fields
clear_inputs() {
    text_file=""
    truncate_lines=1
    default_dir="$HOME"
    last_text_file=""
    last_truncate_lines=1

