# Cron Update Manager

A lightweight, robust Bash script designed to automate daily system updates and package cleanups at **03:00 AM** via `cron`. It intelligently detects the underlying Linux distribution (Ubuntu, Debian, Raspberry Pi OS, DietPi) and adapts the update commands accordingly. Furthermore, it checks for `sudo` privileges dynamically—making it fully compatible with root-only environments like LXC containers or Docker base images.

## Supported Distributions

* **Ubuntu**
* **Debian**
* **Raspberry Pi OS**
* **DietPi**

## Features

* **Smart OS Detection:** Automatically identifies your OS using `/etc/os-release`.
* **Privilege Awareness:** Checks if `sudo` is available; runs commands directly as `root` if `sudo` is missing (e.g., in LXC containers).
* **Automated Cron Scheduling:** Safely registers a daily cron job at 03:00 AM without duplicating existing entries.
* **Optimized Update Routines:** Tailored package manager commands for each supported system, including automated cleanups and dependency removals.

## Installation & Usage

### Cloning and running

1. Clone the repository or download the script:
   ```bash
   git clone [https://github.com/Michdo93/cron-update-manager](https://github.com/Michdo93/cron-update-manager)
   cd cron-update-manager
   ```
2. Make the script executable:
   ```bash
   chmod +x install.sh
   ```
3. Run the installation script:
   ```bash
   sudo ./install.sh
   # Or as root (e.g., in LXC):
   ./install.sh
   ```

### Running without cloning

Alternatively you can run:

```bash
wget https://raw.githubusercontent.com/Michdo93/cron-update-manager/refs/heads/main/install.sh -O - | sh
```

## Cron Job Details

The script adds the following entry to the system crontab:

```cron
0 3 * * * /usr/local/bin/system-auto-update.sh >/dev/null 2>&1
```

## License

MIT License. Feel free to use and modify.
