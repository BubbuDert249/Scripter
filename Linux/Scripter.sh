#!/bin/bash

# --- Check Linux kernel version (must be 2.6+) ---
kernel_version=$(uname -r | cut -d- -f1)  # Get version before dash
major=$(echo "$kernel_version" | cut -d. -f1)
minor=$(echo "$kernel_version" | cut -d. -f2)

if [ "$major" -lt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -lt 6 ]; }; then
    echo "Linux kernel 2.6 or higher required."
    exit 1
fi

# --- Detect zenity ---
if ! command -v zenity >/dev/null 2>&1; then
    echo "Zenity not found. Detecting package manager..."
    if [ -f /etc/debian_version ]; then
        sudo apt install -y zenity
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y zenity || sudo dnf install -y zenity
    elif [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm zenity
    else
        zenity --error --text="Could not detect your Linux distro. Please install zenity manually."
        exit 1
    fi
fi

# --- Pick the .sh file ---
sh_file=$(zenity --file-selection --title="Select a Shell Script" --file-filter="*.sh")
if [ -z "$sh_file" ]; then
    exit 0
fi

# --- Pick output folder ---
output_dir=$(zenity --file-selection --directory --title="Select Output Folder")
if [ -z "$output_dir" ]; then
    exit 0
fi

# --- Get the base name without .sh ---
base_name=$(basename "$sh_file")
app_name="${base_name%.sh}"

# --- Copy and remove .sh extension ---
cp "$sh_file" "$output_dir/$app_name"
chmod +x "$output_dir/$app_name"

# --- Success dialog ---
zenity --info --text="Linux app created successfully:\n$output_dir/$app_name"
