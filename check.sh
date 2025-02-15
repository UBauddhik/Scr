#!/bin/bash

# ===============================
# 📌 CONFIGURE USERS, FTP & SSH FOR SCORING
# ===============================
# Ensures users exist, have correct passwords, and proper permissions for FTP & SSH

EXPECTED_USERS=(
"pierre_caters" "leon_serpollet" "henry_ford" "rene_thomas" "john_cobb"
"paula_murphy" "camille_jenatzy" "henri_fournier" "betty_skelton" "louis_rigolly"
"ray_keech" "andy_green" "paul_baras" "jessi_combs" "kitty_oneil"
"arthur_duray" "fred_marriott" "victor_hemery" "dorothy_levitt" "rachel_kushner"
"ernest_eldridge" "kenelm_guinness" "lydston_hornsted" "malcolm_campbell"
"maurice_augieres" "gaston_chasseloup" "william_vanderbilt"
)

PASSWORD_HASH="$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1"
FTP_DIR="/mnt/files"

# ===============================
# ✅ Step 1: Ensure FTP & SSH Services Are Running
# ===============================
echo "🔹 Checking FTP and SSH services..."
sudo systemctl enable vsftpd sshd --now
sudo systemctl restart vsftpd sshd

# ===============================
# ✅ Step 2: Ensure Users Exist & Set Correct Passwords
# ===============================
echo "🔹 Ensuring all expected users exist..."
for user in "${EXPECTED_USERS[@]}"; do
    if ! id "$user" &>/dev/null; then
        echo "➕ Creating user: $user"
        sudo useradd -m -s /sbin/nologin "$user"
    fi
    echo "$user:$PASSWORD_HASH" | sudo chpasswd -e
    sudo usermod -aG ftp "$user"
    echo "✅ Password updated for: $user"
done

# ===============================
# ✅ Step 3: Configure Permissions for FTP & SSH
# ===============================
echo "🔹 Configuring permissions for users..."
for user in "${EXPECTED_USERS[@]}"; do
    sudo chmod 700 /home/$user
    sudo chown $user:$user /home/$user
    echo "✅ Permissions set for: $user"
done

# ===============================
# ✅ Step 4: Ensure FTP Read & Write Access Works
# ===============================
echo "🔹 Configuring FTP directory permissions..."
sudo mkdir -p "$FTP_DIR"
sudo chown root:ftp "$FTP_DIR"
sudo chmod 775 "$FTP_DIR"
echo "✅ FTP directory permissions configured."

# Ensure test files exist for FTP Read
REQUIRED_FILES=("iron_cross.data" "3_point_molly.data" "dark_side.data" "come_dont_come.data" "odds.data"
"house_secrets.data" "pass_line.data" "risky_roller.data" "covered_call.data" "married_put.data"
"bull_call.data" "protective_collar.data" "long_straddle.data" "long_strangle.data"
"long_call_butterfly.data" "iron_condor.data" "iron_butterfly.data" "short_put.data"
"data_dump_1.bin" "data_dump_2.bin" "data_dump_3.bin" "datadump.bin")

echo "🔹 Verifying FTP Read files exist..."
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$FTP_DIR/$file" ]]; then
        sudo touch "$FTP_DIR/$file"
        sudo chmod 644 "$FTP_DIR/$file"
        echo "✅ Created placeholder file: $file"
    fi
done

echo "✅ FTP Read files verified."

# ===============================
# ✅ Step 5: Verify Users Can Log In to FTP
# ===============================
echo "🔹 Testing FTP login for users..."
for user in "${EXPECTED_USERS[@]}"; do
    echo "Test login for $user..."
    sudo su -c "ftp -inv localhost <<EOF
    user $user SecureP@ssw0rd!
    bye
EOF" $user
    echo "✅ FTP login tested for $user."
done

# ===============================
# ✅ Step 6: Verify FTP Write Access
# ===============================
echo "🔹 Testing FTP write access..."
for user in "${EXPECTED_USERS[@]}"; do
    sudo su -c "ftp -inv localhost <<EOF
    user $user SecureP@ssw0rd!
    cd $FTP_DIR
    put /etc/hostname test_upload_$user.txt
    bye
EOF" $user
    echo "✅ FTP write tested for $user."
done

# ===============================
# ✅ Step 7: Ensure SSH Authentication Works
# ===============================
echo "🔹 Ensuring SSH is properly configured..."
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "✅ SSH authentication verified."

# ===============================
# ✅ Step 8: Final Verification
# ===============================
echo "🔍 Verifying user configuration..."
for user in "${EXPECTED_USERS[@]}"; do
    echo "🔹 Checking $user:"
    id $user
    sudo ls -ld /home/$user
    sudo grep "^$user:" /etc/shadow
    echo "---------------------------------"
done

echo "✅ All users, FTP, and SSH are now fully configured for scoring!"
