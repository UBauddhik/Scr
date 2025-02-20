#!/bin/bash

PCAP_FILE="20110413_pcap_1.pcap"
SERVICES_FILE="ports_services.txt"

echo "[+] Extracting host-to-host communications from $PCAP_FILE"

# Extract communication data (IP addresses, protocols, and ports)
tshark -r "$PCAP_FILE" -T fields -e ip.src -e ip.dst -e ip.proto -e tcp.srcport -e tcp.dstport -e udp.srcport -e udp.dstport > communications_raw.txt

echo "[+] Loading ports and services into memory for faster lookup"

# Load port-to-service mappings into associative arrays for instant lookups
declare -A TCP_SERVICES
declare -A UDP_SERVICES

while read service port_proto; do
    port="${port_proto%/*}"
    proto="${port_proto#*/}"
    if [ "$proto" == "tcp" ]; then
        TCP_SERVICES["$port"]="$service"
    elif [ "$proto" == "udp" ]; then
        UDP_SERVICES["$port"]="$service"
    fi
done < "$SERVICES_FILE"

echo "[+] Mapping ports to services"
echo "Source IP | Destination IP | Protocol | Port | Service | Direction" > network_communications.txt

# Process each line of communication
while read src_ip dst_ip proto tcp_src tcp_dst udp_src udp_dst; do
    # Determine traffic direction (Private IPs = Outbound, Others = Inbound)
    DIRECTION="Outbound"
    [[ "$src_ip" =~ ^192\.168\. || "$src_ip" =~ ^10\. || "$src_ip" =~ ^172\. ]] || DIRECTION="Inbound"

    # TCP Source Port
    if [ -n "$tcp_src" ]; then
        SERVICE="${TCP_SERVICES[$tcp_src]:-Unknown_TCP_Service}"
        echo "$src_ip | $dst_ip | TCP | $tcp_src | $SERVICE | $DIRECTION" >> network_communications.txt
    fi

    # TCP Destination Port
    if [ -n "$tcp_dst" ]; then
        SERVICE="${TCP_SERVICES[$tcp_dst]:-Unknown_TCP_Service}"
        echo "$src_ip | $dst_ip | TCP | $tcp_dst | $SERVICE | $DIRECTION" >> network_communications.txt
    fi

    # UDP Source Port
    if [ -n "$udp_src" ]; then
        SERVICE="${UDP_SERVICES[$udp_src]:-Unknown_UDP_Service}"
        echo "$src_ip | $dst_ip | UDP | $udp_src | $SERVICE | $DIRECTION" >> network_communications.txt
    fi

    # UDP Destination Port
    if [ -n "$udp_dst" ]; then
        SERVICE="${UDP_SERVICES[$udp_dst]:-Unknown_UDP_Service}"
        echo "$src_ip | $dst_ip | UDP | $udp_dst | $SERVICE | $DIRECTION" >> network_communications.txt
    fi
done < communications_raw.txt

echo "[+] Grouping services by host"
echo "Host IP | Services Used" > host_service_mapping.txt

# Extract services used by each host
awk -F '|' '{print $1, $5}' network_communications.txt | sort | uniq >> host_service_mapping.txt
awk -F '|' '{print $2, $5}' network_communications.txt | sort | uniq >> host_service_mapping.txt

sort -u host_service_mapping.txt -o host_service_mapping.txt

echo "[+] Identifying suspicious connections (optional)"
echo "Suspicious Connections (Inbound Unknown Services)" > suspicious_connections.txt
grep "Inbound" network_communications.txt | grep "Unknown" >> suspicious_connections.txt

echo "[+] Cleaning up temporary files"
rm communications_raw.txt

echo "[+] Task 4 Completed Successfully"
echo "- network_communications.txt"
echo "- host_service_mapping.txt"
echo "- suspicious_connections.txt"
