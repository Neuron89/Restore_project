#!/bin/bash

package_list="$HOME/Documents/playbook_project/package_info/pacman.txt"
current_list="/$HOME/Documents/playbook_project/package_info/pacman_current.txt"
missing="/$HOME/Documents/playbook_project/tmp/missing_packages.txt"

#gets the current list of packages
echo "getting current list of packages"
pacman -Qqe > "${current_list}"
sleep 1

#compares the set list to the currently installed packages
echo "comparing list of current packages"
# sed is used to format the output of diff. s/^[<>]// is used to replace anything in the [] with anything inbetween the //. s/^[ \t]// is used to replace any empty spaces at the begining of the line to keep formating clean. the G at the end is to apply this globally. the following sed is to remove the numbers created on the list. 1d deletes he first line; then we skip the next with n; and then delete with d. that will repeat all the way down.
diff ${package_list} ${current_list} | sed 's/^[<>]//;s/^[ \t]//g' | sed '1d; n; d' > "${missing}" 
sleep 1

#displays missing packages
echo "missing packages:"
cat ${missing}
sleep 1

#statement to ask if you want to install the packages
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

#deletes the temp file 
rm "${missing}" "${current_list}"

#updating all packages
sudo pacman -Syu --noconfirm


