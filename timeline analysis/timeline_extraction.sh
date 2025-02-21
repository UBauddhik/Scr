#!/bin/bash

echo "[+] Extracting network events timeline"
tshark -r 20110413_pcap_1.pcap -T fields -e frame.time -e ip.src -e ip.dst -e ip.proto -e tcp.srcport -e tcp.dstport -e udp.srcport -e udp.dstport > timeline_raw.txt

echo "[+] Loading ports and services into memory"
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
done < ports_services.txt

echo "[+] Processing timeline"
echo "Timestamp | Source IP | Destination IP | Protocol | Port | Service" > application_timeline.txt

while read timestamp src_ip dst_ip proto tcp_src tcp_dst udp_src udp_dst; do
    if [ -n "$tcp_src" ]; then
        SERVICE="${TCP_SERVICES[$tcp_src]:-Unknown_TCP_Service}"
        echo "$timestamp | $src_ip | $dst_ip | TCP | $tcp_src | $SERVICE" >> application_timeline.txt
    fi
    if [ -n "$tcp_dst" ]; then
        SERVICE="${TCP_SERVICES[$tcp_dst]:-Unknown_TCP_Service}"
        echo "$timestamp | $src_ip | $dst_ip | TCP | $tcp_dst | $SERVICE" >> application_timeline.txt
    fi
    if [ -n "$udp_src" ]; then
        SERVICE="${UDP_SERVICES[$udp_src]:-Unknown_UDP_Service}"
        echo "$timestamp | $src_ip | $dst_ip | UDP | $udp_src | $SERVICE" >> application_timeline.txt
    fi
    if [ -n "$udp_dst" ]; then
        SERVICE="${UDP_SERVICES[$udp_dst]:-Unknown_UDP_Service}"
        echo "$timestamp | $src_ip | $dst_ip | UDP | $udp_dst | $SERVICE" >> application_timeline.txt
    fi
done < timeline_raw.txt

echo "[✔] Network Timeline Extraction Completed"
