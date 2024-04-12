#!/bin/bash

: '
This script automate user management task and 
backup the processes in linux environment.
'


# --- Function to create new user account ---
create_user() {

	read -p "Enter the new username: " username
	
	# check weather new username already exist
	if id "$username" &>/dev/null 2>&1; then
		echo "Error: The username '$username' already exist. Please use a different username."
	else
		# Create the user account
		sudo useradd -m "$username"
		
		# Set the user password
		sudo passwd "$username"
		echo "User account '$username' created successfully."
	fi

}

# --- Function to modify user account ---
modify_user() {
    read -p "Enter username to modify: " username

    # check if the username exists
    if id "$username" &>/dev/null; then
        read -s -p "Enter the new password for $username: " new_passwd
        echo
        read -s -p "Retype new password: " new_passwd2
        echo

        if [ "$new_passwd" != "$new_passwd2" ]; then
            echo "Passwords do not match. Password change aborted."
        else
            if echo "$username:$new_passwd" | sudo chpasswd; then
                echo "Password for '$username' has been updated."
            else
                echo "Failed to update password for '$username'."
            fi
        fi
    else
        echo "Error: User '$username' does not exist."
    fi
}

# --- Function to delete an existing user ---
delete_user() {
	read -p "Enter username to delete: " username
	
	# check if the username exit
	if id "$username" &>/dev/null 2>&1; then
		sudo userdel -r "$username"   # Remove user and their home directory
	else	
		echo "Error: The username '$username' does not exit. Please enter a valid username."
	fi 
}

# --- Function to create a new group ---
create_group() {
	read -p "Enter the new group name: " grpname
	
	# check if the group name already exists
	if getent group "$grpname" &>/dev/null 2>&1; then
		echo "Error: Group name '$grpname' already exist. Please use a different group name."
	else
		sudo groupadd "$grpname"
		echo "The Group name '$grpname' created successfully."
	fi
}

# --- Function to add a user to a group ---
add_user_to_group() {
	read -p "Enter username: " username
	
	# check the username exits
	if id "$username" &>/dev/null 2>&1; then
		read -p "Enter group name: " grpname
		
		# check the group name exists
		if getent group "$grpname" &>/dev/null 2>&1; then
			sudo usermod -aG "$grpname" "$username"
			echo "The username '$username' has added successfully to a group '$grpname'"
		else
			echo "Error: Group name '$grpname' does not exists. Please enter a valid group name."
		fi
	else
		echo "Error: Username '$username' does not exists. Please enter a valid username."
	fi
}

# --- Function to remove a user from a group ---
remove_user_from_group() {
	read -p "Enter username: " username
	
	# check the username exists
	if id "$username" &>/dev/null 2>&1; then
		read -p "Enter group name: " grpname
		
		# check the group name exists
		if getent group "$grpname" &>/dev/null 2>&1; then
		
			# '-d' remove a user from a group
			sudo gpasswd -d "$username" "$grpname"     
			echo "The username '$username' remove successfully from a group '$grpname'"
		else
			echo "Error: Group name '$grpname' does not exists. Please enter a valid group name."
		fi
	else
		echo "Error: Username '$username' does not exists. Please enter a valid username."
	fi
}

# --- Function to compress and archieve a directory ---
backup_directory() {

	read -p "Enter the source directory path to take backup: " source_dir

	 # Validate the source directory
  	if [ ! -d "$source_dir" ]; then
        	echo "Error: Source directory '$source_dir' does not exist."
        	echo "Backup operation aborted."
        	return 1
    	fi

	read -p "Enter the target directory path to save backup: " target_dir

	# Validat the target directory
	
	# -d checks if a path exists and is a directory.
	# -w checks if a path exists and is writable.
	
	if [ ! -d "$target_dir" ] || [ ! -w "$target_dir" ]; then
		echo "Error: Target directory '$target_dir' does not exit or is not writable."
		echo "Please enter a valid target directory path."
		return 1
	fi		

	local backup_filename="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
	
	tar -czvf "${target_dir}/${backup_filename}" "$source_dir"
	echo "Backup created: '$backup_filename'"
}

# Main menu
for (( ; ; )); do
    clear
    echo "User Management and Backup Script"
    echo "1. Create User Account"
    echo "2. Modify User Account"
    echo "3. Delete User Account"
    echo "4. Create Group"
    echo "5. Add User to Group"
    echo "6. Remove User from Group"
    echo "7. Backup Directory"
    echo "8. Exit"
    read -p "Enter your choice: " choice

    case "$choice" in
        1)
            create_user
            ;;
        2)
            modify_user 
            ;;
        3)
            delete_user
            ;;
        4)
            create_group
            ;;
        5)
            add_user_to_group
	    ;;
        6)
            remove_user_from_group
            ;;
        7)
            backup_directory
            ;;
        8)
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
    read -p "Press Enter to continue..."
done

