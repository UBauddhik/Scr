#!/bin/bash

# Step 3: Verify and correct user home directories
echo "Checking user home directories..."
users="camille_jenatzy gaston_chasseloup leon_serpollet william_vanderbilt henri_fournier \
       maurice_augieres arthur_duray henry_ford louis_rigolly pierre_caters \
       paul_baras victor_hemery fred_marriott lydston_hornsted kenelm_guinness \
       rene_thomas ernest_eldridge malcolm_campbell ray_keech john_cobb dorothy_levitt \
       paula_murphy betty_skelton rachel_kushner kitty_oneil jessi_combs andy_green"

for user in $users; do
    current_home=$(eval echo ~$user)
    if [ "$current_home" != "/mnt/files" ]; then
        echo "Fixing home directory for $user..."
        sudo usermod -d /mnt/files -s /sbin/nologin $user
    fi
done

# Step 4: Ensure correct directory permissions
echo "Setting correct permissions for /mnt/files..."
sudo chown -R root:root /mnt/files
sudo chmod -R 755 /mnt/files

# Step 5: Restart FTP service
echo "Restarting vsftpd service..."
sudo systemctl restart vsftpd
sudo systemctl enable vsftpd

# Step 6: Open firewall ports for FTP
echo "Configuring firewall for FTP..."
sudo firewall-cmd --permanent --add-service=ftp
sudo firewall-cmd --permanent --add-port=40000-50000/tcp
sudo firewall-cmd --reload

# Step 7: Verify FTP Service and Connectivity
echo "Verifying vsftpd service status..."
systemctl status vsftpd --no-pager

echo "Checking if FTP is listening on Port 21..."
sudo netstat -tulpn | grep vsftpd

echo "Checking file presence in /mnt/files..."
files="iron_cross.data 3_point_molly.data dark_side.data come_dont_come.data odds.data \
       .house_secrets.data pass_line.data risky_roller.data covered_call.data \
       married_put.data bull_call.data protective_collar.data long_straddle.data \
       long_strangle.data long_call_butteryfly.data iron_condor.data iron_butterfly.data \
       short_put.data data_dump_1.bin data_dump_2.bin data_dump_3.bin datadump.bin"

for file in $files; do
    if [ ! -f "/mnt/files/$file" ]; then
        echo "Creating missing file: $file"
        sudo touch "/mnt/files/$file"
    fi
done

# Final check
echo "Verifying FTP login..."
ftp -inv localhost <<EOF
user camille_jenatzy TestPassword
ls
bye
EOF

echo "FTP Setup Completed! ✅"
