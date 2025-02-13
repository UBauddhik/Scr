#!/bin/bash

# Script 1: Change Password for All Users to the Same Password
change_all_passwords() {
    echo "Changing all user passwords to a new one..."
    NEW_PASSWORD=$(openssl rand -base64 12)
    for user in $(awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd); do
        echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | sudo passwd "$user"
        echo "Password changed for user: $user"
    done
    echo "All users now have the same password: $NEW_PASSWORD"
}

# Script 2: Change Password for Each User Individually
change_individual_passwords() {
    echo "Changing each user's password individually..."
    for user in $(awk -F: '{ if ($3 >= 1000 && $3 < 60000) print $1 }' /etc/passwd); do
        USER_PASSWORD=$(openssl rand -base64 12)
        echo -e "$USER_PASSWORD\n$USER_PASSWORD" | sudo passwd "$user"
        echo "User: $user | New Password: $USER_PASSWORD"
    done
    echo "Passwords changed for all users."
}

# Script 3: Lock Down Ubuntu Except for FTP, SSH, and VNC
lockdown_system() {
    echo "Locking down the system, allowing only FTP, SSH, and VNC..."
    
    # Allow required services
    sudo ufw allow ssh
    sudo ufw allow ftp
    sudo ufw allow 5900/tcp  # VNC default port
    
    # Enable UFW and set default deny
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
    
    echo "Stopping all unnecessary services..."
    for service in $(systemctl list-units --type=service --state=running | awk '{print $1}' | grep -vE '(ssh|vsftpd|vnc)'); do
        sudo systemctl stop $service
        sudo systemctl disable $service
    done
    
    echo "System lockdown complete. Only FTP, SSH, and VNC are allowed."
}

# Menu for user selection
echo "Select an option:"
echo "1. Change all passwords to the same random password"
echo "2. Change passwords for each user individually"
echo "3. Lock down Ubuntu (except for FTP, SSH, and VNC)"
echo "4. Exit"
read -p "Enter your choice: " choice

case $choice in
    1) change_all_passwords ;;
    2) change_individual_passwords ;;
    3) lockdown_system ;;
    4) exit 0 ;;
    *) echo "Invalid option, exiting." ; exit 1 ;;
esac
