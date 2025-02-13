#!/bin/bash

# Script: Lock Down Ubuntu (Allow Only FTP, SSH, and VNC)
lockdown_system() {
    echo "Locking down the system, allowing only FTP, SSH, and VNC..."
    
    # Set default firewall policies
    sudo ufw default deny incoming
    sudo ufw default allow outgoing  # Ensure internet access is maintained
    
    # Enable access to essential services
    sudo ufw allow ssh
    sudo ufw allow ftp
    sudo ufw allow 5900/tcp  # Default VNC port
    
    # Enable firewall
    sudo ufw enable
    
    echo "Stopping and disabling all unnecessary services..."
    for service in $(systemctl list-units --type=service --state=running | awk '{print $1}' | grep -vE '(ssh|vsftpd|vnc)'); do
        sudo systemctl stop "$service"
        sudo systemctl disable "$service"
    done
    
    echo "System lockdown complete. Only FTP, SSH, and VNC are allowed. Internet access remains enabled."
}

# Execute the function
lockdown_system