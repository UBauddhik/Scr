#!/bin/bash

echo "[+] Extracting unencrypted credentials (FTP, Telnet, HTTP)"
tshark -r 20110413_pcap_1.pcap -Y "ftp || telnet || http.authbasic" -T fields -e frame.time -e ip.src -e ip.dst -e ftp.request.command -e ftp.request.arg -e ftp.response.arg -e telnet.data -e http.authbasic > credentials_raw.txt

echo "[+] Parsing credentials"
awk -F '\t' '{if ($4 == "USER" || $4 == "PASS") print $1, $2, $3, "FTP Credential:", $5; else if ($6 != "") print $1, $2, $3, "Telnet Data:", $6; else if ($7 != "") print $1, $2, $3, "HTTP Basic Auth:", $7}' credentials_raw.txt > credentials_discovered.txt

echo "[✔] Credentials Discovery Completed"
