#!/bin/sh
# Validate UFW application profiles
# Checks INI format, required fields, and port syntax

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILES_DIR="${SCRIPT_DIR}/../app-profiles"
ERRORS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error() {
	printf "%sERROR: %s%s\n" "${RED}" "$1" "${NC}" >&2
	ERRORS=$((ERRORS + 1))
}

info() {
	printf "%sINFO: %s%s\n" "${GREEN}" "$1" "${NC}"
}

# Validate port specification
# Format: port/protocol | start:end/protocol
# Examples: 80/tcp, 443/tcp, 6000:6100/tcp, 53/udp
validate_ports() {
	ports_string="$1"
	profile_name="$2"

	# Split by pipe character
	saved_ifs="${IFS}"
	IFS='|'

	for port_spec in ${ports_string}; do
		# Check for protocol suffix
		case "${port_spec}" in
		*/tcp | */udp)
			# Valid protocol
			;;
		*)
			error "[${profile_name}] Invalid port specification '${port_spec}' - missing /tcp or /udp"
			continue
			;;
		esac

		# Extract port(s)
		port_part="${port_spec%/*}"

		# Check for port range (contains colon)
		case "${port_part}" in
		*:*)
			# Port range - validate start:end format
			start="${port_part%:*}"
			end="${port_part#*:}"

			# Validate start port
			if ! echo "${start}" | grep -qE '^[0-9]+$'; then
				error "[${profile_name}] Invalid start port '${start}' in range '${port_spec}'"
				continue
			fi

			# Validate end port
			if ! echo "${end}" | grep -qE '^[0-9]+$'; then
				error "[${profile_name}] Invalid end port '${end}' in range '${port_spec}'"
				continue
			fi

			# Check range validity
			if [ "${start}" -gt "${end}" ]; then
				error "[${profile_name}] Invalid port range '${port_spec}' - start > end"
				continue
			fi

			# Check port bounds
			if [ "${start}" -lt 1 ] || [ "${start}" -gt 65535 ]; then
				error "[${profile_name}] Start port '${start}' out of range (1-65535)"
				continue
			fi
			if [ "${end}" -lt 1 ] || [ "${end}" -gt 65535 ]; then
				error "[${profile_name}] End port '${end}' out of range (1-65535)"
				continue
			fi
			;;
		*)
			# Single port - validate numeric
			if ! echo "${port_part}" | grep -qE '^[0-9]+$'; then
				error "[${profile_name}] Invalid port number '${port_part}' in '${port_spec}'"
				continue
			fi

			# Check port bounds
			port_num="${port_part}"
			if [ "${port_num}" -lt 1 ] || [ "${port_num}" -gt 65535 ]; then
				error "[${profile_name}] Port '${port_num}' out of range (1-65535)"
				continue
			fi
			;;
		esac
	done

	IFS="${saved_ifs}"
}

# Validate a single profile file
validate_profile() {
	file="$1"
	filename="$(basename "${file}")"

	info "Validating ${filename}"

	# Check file is readable
	if [ ! -r "${file}" ]; then
		error "[${filename}] Cannot read file"
		return
	fi

	# Look for profile section [name]
	profile_name=""
	title=""
	description=""
	ports=""

	while IFS= read -r line || [ -n "${line}" ]; do
		# Skip empty lines and comments
		case "${line}" in
		'' | '#'*) continue ;;
		esac

		# Check for section header
		case "${line}" in
		\[*\])
			profile_name="${line#[}"
			profile_name="${profile_name%]}"

			# Validate section name (lowercase, no spaces, alphanumeric and hyphens)
			if ! echo "${profile_name}" | grep -qE '^[a-z0-9-]+$'; then
				error "[${filename}] Invalid section name '[${profile_name}]' - must be lowercase with hyphens only"
			fi
			continue
			;;
		esac

		# Parse key=value pairs
		case "${line}" in
		title=*)
			title="${line#title=}"
			;;
		description=*)
			description="${line#description=}"
			;;
		ports=*)
			ports="${line#ports=}"
			;;
		esac
	done <"${file}"

	# Check required fields
	if [ -z "${profile_name}" ]; then
		error "[${filename}] Missing section header [profile-name]"
	fi

	if [ -z "${title}" ]; then
		error "[${filename}] Missing required field 'title'"
	fi

	if [ -z "${description}" ]; then
		error "[${filename}] Missing required field 'description'"
	fi

	if [ -z "${ports}" ]; then
		error "[${filename}] Missing required field 'ports'"
	else
		validate_ports "${ports}" "${filename}"
	fi
}

# Main validation loop
main() {
	if [ ! -d "${PROFILES_DIR}" ]; then
		error "Profiles directory not found: ${PROFILES_DIR}"
		exit 1
	fi

	profile_count=0

	for profile_file in "${PROFILES_DIR}"/*; do
		# Skip if no files found
		[ -e "${profile_file}" ] || continue

		# Skip directories
		[ -f "${profile_file}" ] || continue

		profile_count=$((profile_count + 1))
		validate_profile "${profile_file}"
	done

	if [ "${profile_count}" -eq 0 ]; then
		error "No profile files found in ${PROFILES_DIR}"
	fi

	# Summary
	echo ""
	if [ "${ERRORS}" -gt 0 ]; then
		printf "%sValidation failed with %d error(s)%s\n" "${RED}" "${ERRORS}" "${NC}" >&2
		exit 1
	else
		printf "%sValidation passed - %d profile(s) checked%s\n" "${GREEN}" "${profile_count}" "${NC}"
		exit 0
	fi
}

main "$@"
