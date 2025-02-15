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

# Function to verify the integrity of the config file and restore if integrity is lost
verify_and_restore_integrity() {
    echo "[INFO] Verifying integrity of $CONFIG_FILE"

    if [ ! -f "$HASH_FILE" ]; then
        echo "[ERROR] No hash file found. Unable to verify integrity. Exiting..."
        exit 1
    fi

    CURRENT_HASH=$(sha256sum "$CONFIG_FILE" | awk '{print $1}')
    STORED_HASH=$(cat "$HASH_FILE")

    if [ "$CURRENT_HASH" == "$STORED_HASH" ]; then
        echo "[OK] Integrity check passed. No changes detected."
    else
        echo "[ALERT] Integrity check failed. Configuration file has been modified!"

        # Restore from backup if integrity is lost
        if [ -f "$BACKUP_FILE" ]; then
            echo "[INFO] Restoring configuration file from backup..."
            cp "$BACKUP_FILE" "$CONFIG_FILE"
            echo "[SUCCESS] Configuration restored from backup."

            # Recalculate hash after restoration
            sha256sum "$CONFIG_FILE" | awk '{print $1}' > "$HASH_FILE"
            echo "[INFO] Hash updated after restoration."
        else
            echo "[ERROR] No backup file found. Manual intervention required!"
            exit 1
        fi
    fi
}

# Main execution
backup_config
verify_and_restore_integrity

echo "[DONE] Backup, integrity check, and restoration (if needed) complete."
