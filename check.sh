#!/bin/bash

# ===============================
# 📌 VERIFY USERS & FLAG UNEXPECTED USERS
# ===============================
# This script compares system users against the expected list.
# It flags any unexpected users and provides investigative details.

EXPECTED_USERS=(
"pierre_caters" "leon_serpollet" "henry_ford" "rene_thomas" "john_cobb"
"paula_murphy" "camille_jenatzy" "henri_fournier" "betty_skelton" "louis_rigolly"
"ray_keech" "andy_green" "paul_baras" "jessi_combs" "kitty_oneil"
"arthur_duray" "fred_marriott" "victor_hemery" "dorothy_levitt" "rachel_kushner"
"ernest_eldridge" "kenelm_guinness" "lydston_hornsted" "malcolm_campbell"
"maurice_augieres" "gaston_chasseloup" "william_vanderbilt"
)

# Save expected users to a temporary file
echo -e "${EXPECTED_USERS[@]}" | tr ' ' '\n' | sort > expected_users.txt

# Extract all system users and compare against expected list
cut -d' ' -f1 extra_users_shells.txt | sort > all_users.txt
comm -23 all_users.txt expected_users.txt > unexpected_users.txt

# ===============================
# ✅ Step 1: List Unexpected Users
# ===============================
echo "🔹 Checking for unexpected users..."
if [ -s unexpected_users.txt ]; then
    echo "⚠️ The following users exist but are NOT in the expected list:"
    cat unexpected_users.txt
else
    echo "✅ No unexpected users found."
fi

# ===============================
# ✅ Step 2: Investigate Unexpected Users
# ===============================
if [ -s unexpected_users.txt ]; then
    echo "🔍 Investigating unexpected users..."
    while read -r user; do
        echo -e "\n🔹 Checking details for: $user"
        id $user
        sudo grep "^$user:" /etc/passwd
        sudo grep "^$user:" /etc/shadow
        sudo ls -ld /home/$user
    done < unexpected_users.txt
fi

# Cleanup temporary files
rm -f all_users.txt expected_users.txt

echo "✅ Verification complete! Review 'unexpected_users.txt' if needed."
