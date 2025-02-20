#!/bin/bash

PCAP_FILE="20110413_pcap_1.pcap"

echo "[+] Extracting TCP and UDP ports from $PCAP_FILE"

# Extract all TCP and UDP ports (source and destination)
tshark -r "$PCAP_FILE" -Y "tcp" -T fields -e tcp.srcport -e tcp.dstport | tr '\t' '\n' | sort -n | uniq > tcp_ports.txt
tshark -r "$PCAP_FILE" -Y "udp" -T fields -e udp.srcport -e udp.dstport | tr '\t' '\n' | sort -n | uniq > udp_ports.txt

echo "[+] Filtering well-known ports (1-1024)"

# Filter well-known ports (1-1024)
awk '$1 <= 1024' tcp_ports.txt > tcp_well_known.txt
awk '$1 <= 1024' udp_ports.txt > udp_well_known.txt

echo "[+] Matching TCP ports to services"
# Match TCP ports to services
echo "Service Port/Protocol" > ports_services.txt
while read port; do
    SERVICE=$(grep -w "$port/tcp" /etc/services | awk '{print $1, $2}')
    if [ -n "$SERVICE" ]; then
        echo "$SERVICE" >> ports_services.txt
    else
        echo "Unknown_TCP_Port $port/tcp" >> ports_services.txt
    fi
done < tcp_well_known.txt

echo "[+] Matching UDP ports to services"
# Match UDP ports to services
while read port; do
    SERVICE=$(grep -w "$port/udp" /etc/services | awk '{print $1, $2}')
    if [ -n "$SERVICE" ]; then
        echo "$SERVICE" >> ports_services.txt
    else
        echo "Unknown_UDP_Port $port/udp" >> ports_services.txt
    fi
done < udp_well_known.txt

echo "[+] Cleaning up temporary files"
# Cleanup temporary files
rm tcp_ports.txt udp_ports.txt tcp_well_known.txt udp_well_known.txt

echo "[+] Task 3 Completed: Results saved in ports_services.txt"
echo "---------------------------"
cat ports_services.txt
echo "---------------------------"
