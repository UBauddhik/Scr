#!/bin/bash

PCAP_FILE="20110413_pcap_1.pcap"
EXTRACT_DIR="./extracted_files"

echo "[+] Starting Artifact Discovery"

# --------------------- FILE DISCOVERY ---------------------
echo "[+] Extracting file transfers (SMB, FTP, HTTP)"
mkdir -p "$EXTRACT_DIR/http" "$EXTRACT_DIR/smb" "$EXTRACT_DIR/ftp"

tshark -r "$PCAP_FILE" -Y "smb2 || ftp || http" -T fields -e frame.time -e ip.src -e ip.dst -e ftp.request -e ftp.response -e http.request.uri -e http.file_data -e smb2.filename > file_transfers_raw.txt

echo "[+] Saving file information"
awk -F '\t' '{if ($5 != "") print $1, $2, $3, "FTP File:", $5; else if ($6 != "") print $1, $2, $3, "HTTP File:", $6; else if ($7 != "") print $1, $2, $3, "SMB File:", $7}' file_transfers_raw.txt > files_discovered.txt

echo "[+] Attempting file extraction from PCAP"
tshark -r "$PCAP_FILE" --export-object http,"$EXTRACT_DIR/http" --export-object smb,"$EXTRACT_DIR/smb" --export-object ftp-data,"$EXTRACT_DIR/ftp"

echo "[+] Generating file hashes"
if [ "$(find "$EXTRACT_DIR" -type f | wc -l)" -gt 0 ]; then
    for file in $(find "$EXTRACT_DIR" -type f); do
        md5sum "$file" >> file_hashes.txt
        sha256sum "$file" >> file_hashes.txt
        stat --printf='%s bytes\n' "$file" >> file_hashes.txt
    done
else
    echo "[-] No files extracted. PCAP may only contain headers or limited payloads."
fi
echo "[✔] File Discovery Completed"

# --------------------- CREDENTIALS DISCOVERY ---------------------
echo "[+] Extracting unencrypted credentials (FTP, Telnet, HTTP)"
tshark -r "$PCAP_FILE" -Y "ftp || telnet || http.authbasic" -T fields -e frame.time -e ip.src -e ip.dst -e ftp.request.command -e ftp.request.arg -e ftp.response.arg -e telnet.data -e http.authbasic > credentials_raw.txt

echo "[+] Parsing credentials"
awk -F '\t' '{
    if ($4 == "USER" || $4 == "PASS") print $1, $2, $3, "FTP Credential:", $5;
    else if ($6 != "") print $1, $2, $3, "Telnet Data:", $6;
    else if ($7 != "") print $1, $2, $3, "HTTP Basic Auth:", $7;
}' credentials_raw.txt > credentials_discovered.txt
echo "[✔] Credentials Discovery Completed"

# --------------------- PAYLOAD DISCOVERY ---------------------
echo "[+] Searching for Base64, Hex, and ASCII payloads"
tshark -r "$PCAP_FILE" -Y "data-text-lines" -T fields -e data.text > payloads_raw.txt

echo "[+] Filtering payloads"
grep -E '[A-Za-z0-9+/=]{10,}' payloads_raw.txt > payloads_base64.txt
grep -E '([0-9a-fA-F]{2} ){8,}' payloads_raw.txt > payloads_hex.txt
grep -E '[ -~]{50,}' payloads_raw.txt > payloads_ascii.txt

echo "[✔] Payload Discovery Completed"
echo "[✔] Artifact Discovery Completed"
