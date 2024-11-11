#!/bin/bash

package_list="$HOME/Documents/playbook_project/package_info/pacman.txt"
current_list="$HOME/Documents/playbook_project/package_info/pacman_current.txt"
missing="$HOME/Documents/playbook_project/tmp/missing_packages.txt"

#gets the current list of packages
echo "getting current list of packages"
pacman -Qqe > "${current_list}"
sleep 1

#compares the set list to the currently installed packages
echo "comparing list of current packages"
diff ${package_list} ${current_list} | sed 's/^[<>]//;s/^[ \t]//g' | sed '1d; n; d' > "${missing}" 
sleep 1

cat "${missing}"
