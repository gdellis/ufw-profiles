# UFW Profiles

A collection of UFW (Uncomplicated Firewall) application profiles for simplified firewall configuration.

## Overview

UFW app profiles allow you to manage firewall rules for specific applications with a single command.
Instead of manually specifying individual ports, enable or disable all required ports for an
application at once.

## Available Profiles

| Profile | Description | Ports |
| ------- | ----------- | ----- |
| `basic-firewall` | Essential services (SSH, HTTP, HTTPS) | 22/tcp, 80/tcp, 443/tcp |
| `blp-lan` | Bambu Lab 3D Printer (LAN Mode) | 6000-6100/tcp/udp, 8883/tcp, 1883/tcp, 990/tcp |
| `blp-cloud` | Bambu Lab 3D Printer (Cloud Mode) | 8883/tcp, 443/tcp |

## Installation

1. Copy profiles to the UFW application directory:

   ```bash
   sudo cp app-profiles/* /etc/ufw/applications.d/
   ```

2. Reload UFW to recognize new profiles:

   ```bash
   sudo ufw reload
   ```

3. Verify profiles are available:

   ```bash
   sudo ufw app list
   ```

## Usage

### Allow Traffic for a Profile

```bash
sudo ufw allow basic-firewall
```

### Deny Traffic for a Profile

```bash
sudo ufw deny basic-firewall
```

### Remove a Profile Rule

```bash
sudo ufw delete allow basic-firewall
```

### View Profile Details

```bash
sudo ufw app info basic-firewall
```

## Development

### Linting

```bash
# Lint all markdown files
markdownlint-cli2 **/*.md

# Lint all shell scripts
shellcheck **/*.sh

# Lint everything
shellcheck **/*.sh && markdownlint-cli2 **/*.md
```

## Contributing

1. Create a feature branch from `main`
2. Add or update profiles following the format in `AGENTS.md`
3. Run lint commands
4. Submit a pull request

## License

MIT
