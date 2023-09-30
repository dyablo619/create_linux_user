#!/bin/bash
#
# Script that creates a user with password, assigns a permission level
# and it creates the .ssh directory and authorized_key file.
# The file has to be run as a root user.
#
# Author - Sergio Vazquez - dyabl619 - 09/28/2023
# ------------------------------------------------------------------

# We first check if the user is a root user, if it's not then we end the script and return a message to the user.

if [ $(id -u) -eq 0 ]; then
	#first check the type of distribution running

    if [ $(grep -Po "(?<=^ID=).+" /etc/os-release | sed 's/"//g') == "centos" ]; then
		sudo_command="wheel"
    elif [ $(grep -Po "(?<=^ID=).+" /etc/os-release | sed 's/"//g') == "ubuntu" ]; then
		sudo_command="sudo"
    else
		sudo_command="sudo"
    fi

    read -p "Enter username : " username
    echo
    read -p "Enter Permission Level, 1 (sudo), 2 (non-sudo): " permlevel
    echo
    read -s -p "Enter password : " password

    egrep "^$username" /etc/passwd >/dev/null

    #Verify that the new user does not already exist
    if [ $? -eq 0 ]; then
		echo "The user $username alraedy exists."
		exit 1
    else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p "$pass" "$username"

        #checks to see if we have to add this user to the sudo group
        if [ $permlevel -eq 1 ]; then
        usermod -a -G "$sudo_command" "$username"
        fi

        #creatse the directories for the .ssh folder and authorized_keys and sets the appropriate permissions
        mkdir /home/$username/.ssh
        touch /home/$username/.ssh/authorized_keys
        chown $username:$username -R /home/$username/.ssh
        chmod 0700 /home/$username/.ssh
        chmod 0600 /home/$username/.ssh/authorized_keys

        [ $? -eq 0 ] && echo "The user $username has been added to the system." || echo "Unable to add the user $username to the system."
    fi
else
    echo "You do not have root permissions, which are required in order to create a user account."
    exit 2
fi
