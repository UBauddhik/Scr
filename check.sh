#!/bin/bash

# Configuration file to monitor
CONFIG_FILE="/etc/vsftpd.conf"  # Adjust to your target config file

# Backup and hash storage
BACKUP_FILE="/etc/vsftpd.conf.bak"
HASH_FILE="/var/log/vsftpd.conf.hash"

# Function to create a backup of the config file
backup_config() {
    echo "[INFO] Checking for existing backup..."
    if [ ! -f "$BACKUP_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        echo "[INFO] Backup created at $BACKUP_FILE"
    else
        echo "[INFO] Backup already exists at $BACKUP_FILE"
    fi
}

# Function to generate a hash of the config file
generate_hash() {
    echo "[INFO] Generating hash for $CONFIG_FILE"
    sha256sum "$CONFIG_FILE" | awk '{print $1}' > "$HASH_FILE"
    echo "[INFO] Hash saved to $HASH_FILE"
}

# Main execution
backup_config
generate_hash

echo "[DONE] Backup and hash creation complete."
