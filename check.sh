#!/bin/bash

# ===============================
# 📌 CONFIGURE USERS, PERMISSIONS & PASSWORDS
# ===============================
# This script ensures all expected users exist, have correct passwords, and proper permissions.

EXPECTED_USERS=(
"pierre_caters" "leon_serpollet" "henry_ford" "rene_thomas" "john_cobb"
"paula_murphy" "camille_jenatzy" "henri_fournier" "betty_skelton" "louis_rigolly"
"ray_keech" "andy_green" "paul_baras" "jessi_combs" "kitty_oneil"
"arthur_duray" "fred_marriott" "victor_hemery" "dorothy_levitt" "rachel_kushner"
"ernest_eldridge" "kenelm_guinness" "lydston_hornsted" "malcolm_campbell"
"maurice_augieres" "gaston_chasseloup" "william_vanderbilt"
)

PASSWORD_HASH="$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1"

# ===============================
# ✅ Step 1: Ensure Users Exist and Set Correct Password
# ===============================
echo "🔹 Ensuring all expected users exist..."
for user in "${EXPECTED_USERS[@]}"; do
    if ! id "$user" &>/dev/null; then
        echo "➕ Creating user: $user"
        sudo useradd -m -s /sbin/nologin "$user"
    fi
    echo "$user:$PASSWORD_HASH" | sudo chpasswd -e
    echo "✅ Password updated for: $user"
done

# ===============================
# ✅ Step 2: Set Correct Permissions
# ===============================
echo "🔹 Configuring user permissions..."
for user in "${EXPECTED_USERS[@]}"; do
    sudo chmod 700 /home/$user
    sudo chown $user:$user /home/$user
    sudo usermod -aG ftp "$user"
    echo "✅ Permissions set for: $user"
done

# ===============================
# ✅ Step 3: Final Verification
# ===============================
echo "🔍 Verifying user configuration..."
for user in "${EXPECTED_USERS[@]}"; do
    echo "🔹 Checking $user:"
    id $user
    sudo ls -ld /home/$user
    sudo grep "^$user:" /etc/shadow
    echo "---------------------------------"
done

echo "✅ All users configured successfully!"
