# transmission-openvpn-firewall

This project provides a Dockerized setup for running Transmission with OpenVPN, while restricting the container's network access to only a few required domains using a custom `iptables` script.

## Overview

The `setup_container_firewall_template.sh` script ensures that the container only has access to specific domains, such as your VPN provider and GitHub, while blocking all other outbound traffic. This is useful for enhancing security and ensuring that the container communicates only with trusted endpoints.

## Files

### [setup_container_firewall_template.sh](https://github.com/JoAMD/transmission-openvpn-firewall/blob/main/setup_container_firewall_template.sh)

This script configures `iptables` rules to:

- Flush existing `OUTPUT` rules.
- Allow traffic on the loopback interface (`lo`).
- Resolve and allow traffic to specific domains (e.g., your VPN provider and GitHub).
- Allow traffic through the VPN tunnel (`tun0`).
- Block all other outbound traffic by default.

**Usage:**

1. Make the script executable:

   ```bash
   chmod +x setup_container_firewall_template.sh
   ```

2. Run the script with optional logging:

   ```bash
   sudo ./setup_container_firewall_template.sh /path/to/your_log_file.log
   ```

3. The script will apply the firewall rules and execute the container's startup process.

### [docker-compose.yml](https://github.com/JoAMD/transmission-openvpn-firewall/blob/main/docker-compose.yml)

This file defines the Docker service for running Transmission with OpenVPN. Key features include:

- Mounting the `setup_container_firewall_template.sh` script into the container.
- Setting the script as the container's entrypoint to ensure the firewall rules are applied before starting the VPN.
- Configurable environment variables for OpenVPN and Transmission.

**Usage:**

1. Update the `docker-compose.yml` file with your configuration:

   - Replace `/path/to/downloads/` and `/path/to/config/` with your local paths.
   - Set the required environment variables (e.g., `OPENVPN_PROVIDER`, `OPENVPN_USERNAME`, `OPENVPN_PASSWORD`, etc.).

2. Start the container:
   ```bash
   docker-compose up -d
   ```

## Why Use This?

This setup is ideal for users who want to:

- Secure their Transmission + OpenVPN container by restricting network access.
- Ensure that only specific domains (e.g., VPN provider, GitHub) are reachable.
- Share a reusable and customizable solution for container firewalling.

## Related Discussions

Inspired by discussions like [#323](https://github.com/haugene/docker-transmission-openvpn/issues/323).

P.S: I was lazy so Copilot generated this for me :)
