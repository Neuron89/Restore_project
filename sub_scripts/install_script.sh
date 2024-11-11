# check to see if this is the first time running this (is there a pkg list generated already) if its the first time, create the main list.
#figure out how to make it not specific to ME and make it so anyone can create a backup and then use it as need be.
#need to clean up prompts and what is being asked. its confusing what is being updated and which files are being added to or removed.
# check to see what pkg manager is installed and then run a check to see if all pkgs on current list are avaliable on the systems pkg manager. if not, ask if they would like to install another AUR. if no, sort file based on packages that can be installed and then only run that file.
#!/bin/bash

package_list="$HOME/Documents/playbook_project/package_info/pacman.txt"
current_list="/$HOME/Documents/playbook_project/package_info/pacman_current.txt"
missing="/$HOME/Documents/playbook_project/tmp/missing_packages.txt"
extras="/$HOME/Documents/playbook_project/tmp/extra_packages.txt"

# Check last modified date of package_list
last_updated=$(stat -c %y "$package_list" 2>/dev/null)
if [ -n "$last_updated" ]; then
    echo "Package list was last updated on: $last_updated"
fi

#gets the current list of packages
echo "getting current list of packages"
pacman -Qqe > "${current_list}"
sleep 1

#compares the set list to the currently installed packages
echo "comparing list of current packages"

# Find packages in current_list that aren't in package_list
diff ${package_list} ${current_list} | grep "^>" | sed 's/^>//;s/^[ \t]//g' > "${extras}"

# Check if there are extra packages
if [ -s "${extras}" ]; then
    echo -e "\nFound additional packages in your system that are not in package_list:"
    cat "${extras}"
    echo -e "\nWould you like to update package_list with these packages? (y/n)"
    read -r update_choice
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # Create a temporary file with sorted, unique packages
        sort -u "${package_list}" "${extras}" > "${package_list}.tmp"
        # Replace the original file with the merged, sorted list
        mv "${package_list}.tmp" "${package_list}"
        echo "Updated package_list with new packages."
        rm "${extras}"
        exit 0
    fi
fi

# Find packages in package_list that aren't in current_list
diff ${package_list} ${current_list} | grep "^<" | sed 's/^<//;s/^[ \t]//g' > "${missing}"
sleep 1

# Function to display packages with numbers
display_packages() {
    echo "Missing packages:"
    local i=1
    while IFS= read -r package; do
        echo "$i) $package"
        ((i++))
    done < "$missing"
    echo -e "\nPress Enter to install all packages, or enter package numbers (space-separated) to install specific ones:"
}

# Display numbered packages
display_packages

# Read user selection
read -r selection

# Process package selection
if [ -z "$selection" ]; then
    echo "Installing all missing packages..."
    while read -r package; do
        sudo pacman -S --noconfirm "$package"
    done < "$missing"
else
    # Convert missing packages file to array
    mapfile -t packages < "$missing"
    
    # Process each selected number
    for num in $selection; do
        if [ "$num" -le "${#packages[@]}" ] && [ "$num" -gt 0 ]; then
            index=$((num - 1))
            echo "Installing ${packages[$index]}..."
            sudo pacman -S --noconfirm "${packages[$index]}"
        else
            echo "Invalid selection: $num"
        fi
    done
fi

#deletes the temp files
rm "${missing}" "${current_list}" "${extras}" 2>/dev/null

#updating all packages
sudo pacman -Syu --noconfirm


