#!/bin/bash

# Usage
# chmod +x setup_container_firewall.sh
# sudo ./setup_container_firewall.sh /path/to/your_log_file.log


# =============================
# Configurable Variables
# =============================
VPN_DOMAIN="" # See this repo for your providers domains in LOCATIONS.txt https://github.com/Zomboided/service.vpn.manager.providers/tree/master
INTERNAL_DNS="" # not used currently
LOG_PATH=${1:-"/var/log/container_firewall.log"}

echo "[$(date)] Starting container firewall setup..." | tee -a "$LOG_PATH"

# =============================
# Reset Existing Rules
# =============================
iptables -F OUTPUT
iptables -X
echo "[$(date)] Flushed existing OUTPUT rules" | tee -a "$LOG_PATH"

# =============================
# Allow localhost
# =============================
iptables -A OUTPUT -o lo -j ACCEPT
echo "[$(date)] Allowed traffic on loopback (lo)" | tee -a "$LOG_PATH"

# =============================
# Function to Resolve Domain and Allow Traffic
# =============================
allow_domain_ips() {
    local domain=$1
    local log_message=$2
    local ips=$(dig +short "$domain" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 8)

    for ip in $ips; do
        iptables -A OUTPUT -d "$ip" -p udp -j ACCEPT
        iptables -A OUTPUT -d "$ip" -p tcp -j ACCEPT
        echo "[$(date)] $log_message $ip (UDP+TCP)" | tee -a "$LOG_PATH"
    done
}

# =============================
# Resolve VPN domain to IPs
# =============================
allow_domain_ips "$VPN_DOMAIN" "Allowed non-VPN traffic to"

# =============================
# Allow GitHub traffic
# =============================
allow_domain_ips "github.com" "Allowed traffic to GitHub"

# =============================
# Allow DNS to VPN DNS
# =============================
# iptables -A OUTPUT -d "$INTERNAL_DNS" -p udp --dport 53 -j ACCEPT
# iptables -A OUTPUT -d "$INTERNAL_DNS" -p tcp --dport 53 -j ACCEPT
# echo "[$(date)] Allowed DNS to $INTERNAL_DNS (UDP+TCP 53)" | tee -a "$LOG_PATH"

# =============================
# Allow VPN tunnel traffic
# =============================
iptables -A OUTPUT -o tun0 -j ACCEPT
echo "[$(date)] Allowed all traffic through tun0" | tee -a "$LOG_PATH"

# =============================
# Allow traffic to local IP range
# =============================
iptables -A OUTPUT -d x.x.x.x/x -j ACCEPT
echo "[$(date)] Allowed outbound traffic to local IP range" | tee -a "$LOG_PATH"

# =============================
# Final DROP Rule
# =============================
iptables -A OUTPUT -j DROP
echo "[$(date)] Dropped all other outbound traffic" | tee -a "$LOG_PATH"

echo "[$(date)] Firewall rules applied successfully!" | tee -a "$LOG_PATH"

echo "[$(date)] Executing rest of the container startup process" | tee -a "$LOG_PATH"
exec "$@"

# References:
# https://linux.die.net/man/1/dig
# https://github.com/Zomboided/service.vpn.manager.providers/tree/master 
# ChatGPT