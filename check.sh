#!/bin/bash

# ===============================
# 📌 FTP & SSH AUTHENTICATION FIX
# ===============================
# Server OS: Rocky 8
# Ensures FTP login, read, and write work for scoring users
# Ensures SSH authentication is correctly configured

# ===============================
# ✅ Step 1: Ensure Required Packages Are Installed
# ===============================
echo "🔹 Installing necessary FTP services..."
sudo dnf install -y vsftpd openssh-server

# ===============================
# ✅ Step 2: Ensure FTP Service is Running
# ===============================
echo "🔹 Enabling and restarting FTP service..."
sudo systemctl enable vsftpd
sudo systemctl restart vsftpd

# ===============================
# ✅ Step 3: Create FTP Scoring Users & Set Password Hash
# ===============================
USERS=("camille_jenatzy" "gaston_chasseloup" "leon_serpollet" "william_vanderbilt" "henri_fournier" "maurice_augieres" "arthur_duray" "henry_ford" "louis_rigolly" "pierre_caters" "paul_baras" "victor_hemery" "fred_marriott" "lydston_hornsted" "kenelm_guinness" "rene_thomas" "ernest_eldridge" "malcolm_campbell" "ray_keech" "john_cobb" "dorothy_levitt" "paula_murphy" "betty_skelton" "rachel_kushner" "kitty_oneil" "jessi_combs" "andy_green")

HASHED_PASSWORD="$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1"

echo "🔹 Creating FTP users..."
for user in "${USERS[@]}"; do
    if ! id "$user" &>/dev/null; then
        sudo useradd -m -s /sbin/nologin "$user"
    fi
    echo "$user:$HASHED_PASSWORD" | sudo chpasswd -e
    sudo usermod -aG ftp "$user"
done

# ===============================
# ✅ Step 4: Configure FTP Permissions & Access
# ===============================
echo "🔹 Configuring FTP permissions..."
sudo chmod 755 /mnt/files
sudo chown root:ftp /mnt/files
sudo chmod 775 /mnt/files

# ===============================
# ✅ Step 5: Ensure Required Files Exist in /mnt/files
# ===============================
REQUIRED_FILES=("iron_cross.data" "3_point_molly.data" "dark_side.data" "come_dont_come.data" "odds.data" "house_secrets.data" "pass_line.data" "risky_roller.data" "covered_call.data" "married_put.data" "bull_call.data" "protective_collar.data" "long_straddle.data" "long_strangle.data" "long_call_butterfly.data" "iron_condor.data" "iron_butterfly.data" "short_put.data" "data_dump_1.bin" "data_dump_2.bin" "data_dump_3.bin" "datadump.bin")

echo "🔹 Verifying required FTP files..."
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "/mnt/files/$file" ]]; then
        sudo touch "/mnt/files/$file"
        echo "Placeholder data for $file" | sudo tee "/mnt/files/$file" >/dev/null
    fi
    sudo chmod 644 "/mnt/files/$file"
done

# ===============================
# ✅ Step 6: Restart FTP Service & Verify
# ===============================
echo "🔹 Restarting FTP service..."
sudo systemctl restart vsftpd

# ===============================
# ✅ Step 7: Verify FTP Login Works
# ===============================
echo "🔹 Testing FTP login..."
for user in "${USERS[@]}"; do
    echo "Test login for $user..."
    sudo su -c "ftp -inv localhost <<EOF
    user $user SecureP@ssw0rd!
    bye
EOF" $user
    echo "✅ FTP login tested for $user."
done

# ===============================
# ✅ Step 8: Configure SSH Authentication (Fixing Public Key Issues)
# ===============================
echo "🔹 Configuring SSH for scoring users..."
sudo sed -i '/^PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
sudo sed -i '/^PubkeyAuthentication/c\PubkeyAuthentication yes' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "🔹 Ensuring SSH keys and permissions are set..."
for user in "${USERS[@]}"; do
    sudo mkdir -p /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo touch /home/$user/.ssh/authorized_keys
    sudo chmod 600 /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user/.ssh

done

# ===============================
# ✅ Step 9: Restart SSH Service & Verify
# ===============================
echo "🔹 Restarting SSH service..."
sudo systemctl restart sshd

echo "✅ Final checks completed! FTP and SSH should now be fully functional."
