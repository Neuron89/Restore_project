#!/bin/bash

package_list="/home/neuron/Documents/playbook_project/pacman.txt"
current_list="/home/neuron/Documents/playbook_project/pacman_current.txt"
missing="/home/neuron/Documents/playbook_project/missing_packages.txt"

#gets the current list of packages
echo "getting current list of packages"
pacman -Qqe > "${current_list}"

#compares the set list to the currently installed packages
echo "comparing list of current packages"
diff ${package_list} ${current_list} > "${missing}" 

#displays missing packages
echo "missing packages:"
cat ${missing}

while true; do
    read -p "Install missing packages? (y/n): " yn
    case $yn in
        [Yy]* ) echo "Installing missing packages..."
                # Read packages from the missing packages file and install them
                while read -r package; do
                    sudo pacman -S --noconfirm "$package"
                done < "$missing"
                break;;
        [Nn]* ) echo "Exiting..."
                exit;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done

rm /home/neuron/Documents/playbook_project/missing_packages.txt

