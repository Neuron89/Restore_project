# add a zip function the backedup home directory 
# check for current back up folder and ask if it should be overwritten or change name?




#!/bin/bash

# Check if pv is installed
if ! command -v pv >/dev/null 2>&1; then
    echo "Installing pv (pipe viewer) for progress bar..."
    sudo pacman -S --noconfirm pv
fi

# List all subdirectories and create selection menu
echo "Available directories in /home/neuron/:"
dirs=()
while IFS= read -r dir; do
    if [ -d "/home/neuron/$dir" ]; then
        dirs+=("$dir")
    fi
done < <(ls -A /home/neuron/)

# Print directories with numbers
for i in "${!dirs[@]}"; do
    echo "$((i+1))) ${dirs[$i]}"
done

# Get user selection
selected_dirs=()
while true; do
    echo -e "\nEnter the number of the directory to backup (or 'done' to finish selecting):"
    read choice
    
    if [[ "$choice" == "done" ]]; then
        break
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#dirs[@]}" ]; then
        selected_dirs+=("${dirs[$((choice-1))]}")
        echo "Added ${dirs[$((choice-1))]} to selection"
    else
        echo "Invalid selection. Please try again."
    fi
done

if [ ${#selected_dirs[@]} -eq 0 ]; then
    echo "No directories selected. Exiting."
    exit 1
fi

# Create the tar command with selected directories
tar_dirs=""
for dir in "${selected_dirs[@]}"; do
    tar_dirs+=" /home/neuron/$dir"
done

# Calculate total size for progress bar
echo "Calculating size..."
total_size=$(du -sb $tar_dirs | awk '{sum += $1} END {print sum}')

# Make a copy of selected directories
echo "Making a temp copy of selected directories..."
tar cf - $tar_dirs 2>/dev/null | pv -s $total_size | tar xf - -C /home/neuron/Documents/playbook_project/tmp/
mv /home/neuron/Documents/playbook_project/tmp/home/neuron /home/neuron/Documents/playbook_project/tmp/home.bak
rm -rf /home/neuron/Documents/playbook_project/tmp/home

