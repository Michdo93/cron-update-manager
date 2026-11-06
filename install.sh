#!/usr/bin/env sh
#
# Auto-Update Installer for Ubuntu, Debian, Raspberry Pi OS, and DietPi
# Runs daily at 03:00 AM via cron.

set -e

# Get current user ID portably (works in dash, bash, sh)
USER_ID="$(id -u)"

# Ensure script is run with administrative privileges
if [ "$USER_ID" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
    echo "[-] Error: This script must be run as root or with sudo privileges." >&2
    exit 1
fi

# Determine wrapper for root commands (empty if already root)
if [ "$USER_ID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "[+] Detecting Linux distribution..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="$ID"
    OS_ID_LIKE="$ID_LIKE"
else
    echo "[-] Error: /etc/os-release not found. Cannot determine OS." >&2
    exit 1
fi

# Define update commands based on distribution
UPDATE_COMMANDS=""

case "$OS_ID" in
    ubuntu)
        echo "[+] Detected: Ubuntu"
        UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y && apt-get clean"
        ;;
    debian)
        echo "[+] Detected: Debian"
        UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get full-upgrade -y && apt-get autoremove -y && apt-get clean"
        ;;
    raspbian)
        echo "[+] Detected: Raspberry Pi OS"
        UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean"
        ;;
    dietpi)
        echo "[+] Detected: DietPi"
        UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean"
        ;;
    *)
        if echo "$OS_ID_LIKE" | grep -qE "debian|ubuntu"; then
            echo "[+] Detected Debian/Ubuntu derivative: $OS_ID"
            UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean"
        else
            echo "[-] Error: Unsupported distribution: $OS_ID" >&2
            exit 1
        fi
        ;;
esac

TARGET_SCRIPT="/usr/local/bin/system-auto-update.sh"

echo "[+] Creating update script at $TARGET_SCRIPT..."

# Write update script depending on root/sudo status
if [ -z "$SUDO" ]; then
    cat << EOF > "$TARGET_SCRIPT"
#!/usr/bin/env bash
# Generated automatic update script
export DEBIAN_FRONTEND=noninteractive
$UPDATE_COMMANDS
EOF
    chmod +x "$TARGET_SCRIPT"
else
    sudo sh -c "cat << 'EOF' > $TARGET_SCRIPT
#!/usr/bin/env bash
# Generated automatic update script
export DEBIAN_FRONTEND=noninteractive
$UPDATE_COMMANDS
EOF"
    sudo chmod +x "$TARGET_SCRIPT"
fi

echo "[+] Setting up cron job for daily execution at 03:00 AM..."

CRON_JOB="0 3 * * * $TARGET_SCRIPT >/dev/null 2>&1"

# Check and set crontab safely without duplicates
if [ -z "$SUDO" ]; then
    (crontab -l 2>/dev/null | grep -F "$TARGET_SCRIPT") && echo "[*] Cron job already exists. Skipping addition." || \
    ((crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab - && echo "[+] Cron job successfully added.")
else
    (sudo crontab -l 2>/dev/null | grep -F "$TARGET_SCRIPT") && echo "[*] Cron job already exists. Skipping addition." || \
    ((sudo crontab -l 2>/dev/null; echo "$CRON_JOB") | sudo crontab - && echo "[+] Cron job successfully added.")
fi

echo "[+] Installation complete! System updates will run daily at 03:00 AM."
