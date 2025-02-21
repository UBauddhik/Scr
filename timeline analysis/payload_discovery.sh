#!/bin/bash

echo "[+] Searching for Base64, Hex, and ASCII payloads"
tshark -r 20110413_pcap_1.pcap -Y "data-text-lines" -T fields -e data.text > payloads_raw.txt

echo "[+] Filtering payloads"
grep -E '[A-Za-z0-9+/=]{8,}' payloads_raw.txt > payloads_base64.txt
grep -E '([0-9a-fA-F]{2} ){8,}' payloads_raw.txt > payloads_hex.txt
grep -E '[ -~]{8,}' payloads_raw.txt > payloads_ascii.txt

echo "[✔] Payload Discovery Completed"
