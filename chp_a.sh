#!/bin/bash

# Script: Change Password for All Users to the Same Password
change_all_passwords() {
    echo "Changing all user passwords to a new one..."
    NEW_PASSWORD=$(openssl rand -base64 12)
    for user in $(awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd); do
        echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | sudo passwd "$user"
        echo "Password changed for user: $user"
    done
    echo "All users now have the same password: $NEW_PASSWORD"
}

# Execute the function
change_all_passwords