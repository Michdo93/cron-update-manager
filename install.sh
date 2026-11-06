#!/usr/bin/env sh
#
# Auto-Update Installer for Ubuntu, Debian, Raspberry Pi OS, and DietPi
# Runs daily at 03:00 AM via cron.

set -e

# Get current user ID portably for sh/bash
USER_ID=$(id -u)

# Ensure script is run with administrative privileges (either root or sudoable user)
if [ "$USER_ID" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
    echo "[-] Error: This script must be run as root or with sudo privileges." >&2
    exit 1
fi

# Determine wrapper for root commands
if [ "$USER_ID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

echo "[+] Detecting Linux distribution..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
    OS_ID_LIKE=$ID_LIKE
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
        # DietPi often uses apt or dietpi-update. Standard apt commands are safe and efficient here.
        UPDATE_COMMANDS="apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get clean"
        ;;
    *)
        # Fallback check for ID_LIKE if specific ID doesn't match
        if [[ "$OS_ID_LIKE" == *"debian"* ]] || [[ "$OS_ID_LIKE" == *"ubuntu"* ]]; then
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

$SUDO bash -c "cat << 'EOF' > $TARGET_SCRIPT
#!/usr/bin/env bash
# Generated automatic update script
export DEBIAN_FRONTEND=noninteractive
$UPDATE_COMMANDS
EOF"

$SUDO chmod +x "$TARGET_SCRIPT"

echo "[+] Setting up cron job for daily execution at 03:00 AM..."

CRON_JOB="0 3 * * * $TARGET_SCRIPT >/dev/null 2>&1"

# Check if cron job already exists to prevent duplicates
(
    $SUDO crontab -l 2>/dev/null | grep -F "$TARGET_SCRIPT"
) && echo "[*] Cron job already exists. Skipping addition." || (
    ($SUDO crontab -l 2>/dev/null; echo "$CRON_JOB") | $SUDO crontab -
    echo "[+] Cron job successfully added."
)

echo "[+] Installation complete! System updates will run daily at 03:00 AM."
