#!/bin/bash

echo "Select the module to run:"
echo "1. File Discovery"
echo "2. Credentials Discovery"
echo "3. Payload Discovery"
echo "4. Full Network Timeline"
echo "5. Run All Modules"

read -p "Enter your choice (1-5): " choice

case $choice in
    1) bash file_discovery.sh ;;
    2) bash credentials_discovery.sh ;;
    3) bash payload_discovery.sh ;;
    4) bash timeline_extraction.sh ;;
    5) 
        bash file_discovery.sh
        bash credentials_discovery.sh
        bash payload_discovery.sh
        bash timeline_extraction.sh
        ;;
    *) echo "Invalid choice! Please enter a number between 1 and 5." ;;
esac
