#!/bin/bash

# Script: Change Password for Each User Individually
change_individual_passwords() {
    echo "Changing each user's password individually..."
    declare -A user_passwords
    
    for user in $(awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd); do
        read -sp "Enter new password for $user: " USER_PASSWORD
        echo
        echo -e "$USER_PASSWORD\n$USER_PASSWORD" | sudo passwd "$user"
        user_passwords[$user]=$USER_PASSWORD
        echo "Password changed for user: $user"
    done
    
    echo "\nPassword changes summary:"
    for user in "${!user_passwords[@]}"; do
        echo "User: $user | New Password: ${user_passwords[$user]}"
    done
}

# Execute the function
change_individual_passwords
