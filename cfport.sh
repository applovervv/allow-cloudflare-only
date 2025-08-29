#!/bin/bash

# Original Source : https://gist.github.com/Manouchehri/cdd4e56db6596e7c3c5a


# Source:
# https://www.cloudflare.com/ips
# https://support.cloudflare.com/hc/en-us/articles/200169166-How-do-I-whitelist-CloudFlare-s-IP-addresses-in-iptables-

# Check if port is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <port>"
    echo "Example: $0 8081"
    exit 1
fi

PORT=$1

# Validate port number
if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
    echo "Error: Invalid port number. Please provide a valid port (1-65535)."
    exit 1
fi

echo "Configuring firewall to allow only Cloudflare IPs on port $PORT"

# Allow Cloudflare IPv4 addresses
echo "Adding Cloudflare IPv4 addresses..."
for i in `curl -s https://www.cloudflare.com/ips-v4`; do 
    iptables -I INPUT -p tcp --dport $PORT -s $i -j ACCEPT
    echo "Added IPv4: $i"
done

# Allow Cloudflare IPv6 addresses
echo "Adding Cloudflare IPv6 addresses..."
for i in `curl -s https://www.cloudflare.com/ips-v6`; do 
    ip6tables -I INPUT -p tcp --dport $PORT -s $i -j ACCEPT
    echo "Added IPv6: $i"
done

# Block all other traffic to this port
echo "Blocking all other traffic to port $PORT..."
iptables -A INPUT -p tcp --dport $PORT -j DROP
ip6tables -A INPUT -p tcp --dport $PORT -j DROP

echo ""
echo "Firewall configuration complete!"
echo "Port $PORT is now accessible only from Cloudflare IPs."
echo ""
echo "WARNING: If Cloudflare drops your service, port $PORT will be unreachable."
echo "WARNING: This does NOT block Cloudflare Workers from accessing your server."
echo ""
echo "To remove these rules later, you can:"
echo "  iptables -F INPUT"
echo "  ip6tables -F INPUT"
echo "  (This will remove ALL INPUT rules, so be careful!)"