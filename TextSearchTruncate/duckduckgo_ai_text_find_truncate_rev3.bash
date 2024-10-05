#!/bin/bash

# ...

# Function to create directories if they don't exist
create_directories() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        echo "Created directory: $dir_path" | tee -a "$log_file"
    fi
}

# Function to log messages
log_message() {
    local message="$1"
    local log_file_path="$script_dir/logs/truncate-file.log"
    create_directories "$(dirname "$log_file_path")"
    echo "$message" | tee -a "$log_file_path"
}

# Function to truncate files
truncate_files() {
    for file in $text_files; do
        if [ ! -f "$file" ]; then
            log_message "Error: File $file does not exist."
            continue
        elif [ ! -r "$file" ]; then
            log_message "Error: You do not have permission to read file $file."
            continue
        elif [ ! -s "$file" ]; then
            log_message "Error: File $file is empty."
            continue
        fi

        if [ -n "$output_file_name" ]; then
            output_file="${file%.*}_${output_file_name}.txt"
        else
            output_file="${file}.truncated"
        fi

        output_dir=$(dirname "$output_file")
        create_directories "$output_dir"

        if ! head -n "$truncate_lines" "$file" > "$output_file"; then
            log_message "Error: Failed to truncate file $file."
            continue
        fi

        log_message "File $file truncated successfully"
    done
    log_message "Files truncated successfully"
}

# Main program
get_text_files
get_truncate_lines
get_output_file_name
confirm_truncation
truncate_files

