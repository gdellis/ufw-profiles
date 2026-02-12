# AGENTS.md - UFW Profile Repository Guidelines

## Repository Purpose

This project sets up a system's firewall using UFW (Uncomplicated Firewall) with custom application rules and profiles. It provides a collection of pre-defined application profiles that simplify firewall configuration for common services and applications.

UFW app profiles allow users to manage firewall rules for specific applications with a single command: `ufw allow <profile-name>`. Instead of manually specifying individual ports, users can enable/disable all required ports for an application at once.

## Project Structure

```
ufw-profiles/
├── README.md              # Project documentation
├── AGENTS.md              # This file - guidelines for AI agents
└── app-profiles/          # UFW application profile definitions
    ├── bambu-printer-lan
    ├── bambu-printer-cloud
    └── ...                # Additional profile files
```

## Build/Lint/Test Commands

This is a configuration-only repository with no build process or tests.

### Lint Commands

```bash
# Lint all shell scripts
shellcheck **/*.sh

# Lint a single shell script
shellcheck path/to/script.sh

# Lint all markdown files
markdownlint **/*.md

# Lint a single markdown file
markdownlint path/to/file.md

# Lint all files (run both linters)
shellcheck **/*.sh && markdownlint **/*.md
```

### Validation Commands

```bash
# Check syntax of a single profile (validate INI format)
sudo ufw app info <profile-name>

# List all available profiles after installation
sudo ufw app list

# View detailed info for a profile
sudo ufw app info <profile-name>

# Test profile installation (dry-run style)
# Profiles should be placed in /etc/ufw/applications.d/
```

### Installing Profiles

```bash
# Copy profiles to UFW application directory
sudo cp app-profiles/* /etc/ufw/applications.d/

# Reload UFW to recognize new profiles
sudo ufw reload
```

### Using Profiles

```bash
# Allow traffic for a profile
sudo ufw allow <profile-name>

# Deny traffic for a profile
sudo ufw deny <profile-name>

# Delete rule for a profile
sudo ufw delete allow <profile-name>
```

## Code Style Guidelines

### UFW Profile File Format

UFW application profiles use INI-style format with specific required fields:

```ini
[profile-name]
title=Human Readable Title
description=Detailed description of what ports are for
ports=port-specification
```

### Profile Naming Conventions

- **Directory**: Use `app-profiles/` for all profile definitions
- **Filename**: Use lowercase with hyphens, e.g., `my-app-name`
- **Profile section name**: Short identifier in brackets, e.g., `[myapp]`
- **Keep filename and section name related but not necessarily identical**

### Required Fields

1. **Section header**: `[profile-name]` - must be lowercase, no spaces
2. **title**: Human-readable name for display purposes
3. **description**: Explain what the application does and why ports are needed
4. **ports**: Port specification string (see below)

### Port Specification Syntax

The `ports` field uses pipe (`|`) to separate multiple port rules:

```
ports=80/tcp|443/tcp|8080:8090/tcp|53/udp
```

**Format components:**
- Single port: `80/tcp` or `53/udp`
- Port range: `6000:6100/tcp` (inclusive range)
- Protocol: Must specify `/tcp` or `/udp`
- Multiple rules: Join with `|` (pipe character)

**Examples:**

```ini
# Web server
ports=80/tcp|443/tcp

# Port range
ports=6000:6100/tcp|6000:6100/udp

# Mixed protocols
ports=1883/tcp|8883/tcp|990/tcp|6000:6100/tcp|6000:6100/udp
```

### Title and Description Style

- **title**: Short, descriptive name (avoid "ports for..." - just the app name)
- **description**: Explain the purpose and context; mention if it's for LAN, cloud, or both

**Good example:**
```ini
title=Bambu Lab 3D Printer (LAN Mode)
description=Ports required for local network communication with Bambu Lab printer
```

**Avoid:**
```ini
title=Ports for Bambu Printer
description=Opens ports
```

### File Organization

- One profile per file for complex applications
- Related profiles can share a file with multiple sections
- Use descriptive filenames that indicate the application

## Error Handling

Since these are configuration files:

1. **Invalid port syntax** - UFW will reject the profile silently or show error on `ufw app info`
2. **Duplicate profile names** - Later definitions override earlier ones
3. **Missing fields** - Profile may not function correctly

### Common Issues

- Missing protocol suffix (`/tcp` or `/udp`)
- Using spaces instead of pipes (`|`) between ports
- Section name with spaces (use hyphens instead)
- Port range using incorrect syntax (use colon `:`)

## Best Practices

1. **Document the source** - Include reference to official documentation for port requirements
2. **Separate modes** - Use separate profiles for LAN vs cloud modes of the same app
3. **Minimal ports** - Only include ports actually required for the application
4. **Clear naming** - Make profile names self-explanatory
5. **Version control** - Keep profiles in this repo for tracking changes

## Creating New Profiles

1. Research required ports from official application documentation
2. Create new file in `app-profiles/` directory
3. Follow the INI format with all required fields
4. Use descriptive naming for file and profile section
5. Specify both TCP and UDP where applicable
6. Test with `sudo ufw app info <profile-name>` after installation

## Example Profile

```ini
[mqtt-broker]
title=MQTT Broker
description=Standard MQTT broker ports for IoT messaging (unencrypted and TLS)
ports=1883/tcp|8883/tcp
```

## Notes for AI Agents

- This is NOT a code project - no compilation or testing frameworks
- Focus on correct INI syntax and port specification format
- When adding profiles, verify port numbers from official sources
- Prefer individual files per application for better organization
- Always include the protocol suffix on every port specification