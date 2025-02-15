sudo mkdir -p /mnt/files
cd /mnt/files

# Create the required files
for file in iron_cross.data 3_point_molly.data dark_side.data come_dont_come.data odds.data \
             .house_secrets.data pass_line.data risky_roller.data covered_call.data \
             married_put.data bull_call.data protective_collar.data long_straddle.data \
             long_strangle.data long_call_butteryfly.data iron_condor.data iron_butterfly.data \
             short_put.data data_dump_1.bin data_dump_2.bin data_dump_3.bin datadump.bin
do
    touch "$file"
done

# Set proper ownership and permissions
sudo chown -R root:root /mnt/files
sudo chmod -R 755 /mnt/files
