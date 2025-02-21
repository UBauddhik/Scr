#!/bin/bash

echo "[+] Extracting file transfers (SMB, FTP, HTTP)"
tshark -r 20110413_pcap_1.pcap -Y "smb2 || ftp || http" -T fields -e frame.time -e ip.src -e ip.dst -e ftp.request -e ftp.response -e http.request.uri -e http.file_data -e smb2.filename > file_transfers_raw.txt

echo "[+] Saving file information"
awk -F '\t' '{if ($5 != "") print $1, $2, $3, "FTP File:", $5; else if ($6 != "") print $1, $2, $3, "HTTP File:", $6; else if ($7 != "") print $1, $2, $3, "SMB File:", $7}' file_transfers_raw.txt > files_discovered.txt

echo "[+] Extracting files from PCAP"
mkdir -p extracted_files/{http,smb,ftp}
tshark -r 20110413_pcap_1.pcap --export-object http,./extracted_files/http --export-object smb,./extracted_files/smb --export-object ftp,./extracted_files/ftp

echo "[+] Generating file hashes"
for file in $(find ./extracted_files -type f); do
    md5sum "$file" >> file_hashes.txt
    sha256sum "$file" >> file_hashes.txt
done

echo "[✔] File Discovery Completed"
