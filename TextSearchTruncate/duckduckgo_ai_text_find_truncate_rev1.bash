#!/bin/bash

# Set the initial text file and truncation lines
text_file=""
truncate_lines=1

# Function to get user input for the text file
get_text_file() {
    while true; do
        text_file=$(zenity --file-selection --title="Select Text File" --filename="$HOME" --file-filter="Text files | *.txt" --style="background-color:#282A36;color:#F8F8F2;font-size:14px")
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
}

# Function to process the file and display the output
process_file() {
    if [ ! -f "$text_file" ]; then
        notify_user "Error" "The selected file does not exist or is not a regular file."
        return
    elif [ ! -r "$text_file" ]; then
        notify_user "Error" "You do not have permission to read the selected file."
        return
    fi

    # Truncate and output the last line(s)
    last_lines=$(cat "$text_file" | tail -n "$truncate_lines")
    echo "$last_lines"

    # Display a notification with the last line(s)
    notify_user "Last $truncate_lines Line(s)" "$last_lines"
}

# Main function to run the script
run_script() {
    get_text_file
    if [ -n "$text_file" ]; then
        get_truncate_lines
        process_file
    fi
}

# Keyboard shortcuts
bind_shortcuts() {
    # Ctrl+Enter to submit the inputs
    bind -x '"\C-m": run_script'

    # Ctrl+C to clear the inputs
    bind -x '"\C-c": clear_inputs'
}

# Run the script
bind_shortcuts
run_script
