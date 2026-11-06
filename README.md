# cron-update-manager
A lightweight, robust Bash script designed to automate daily system updates and package cleanups at **03:00 AM** via `cron`. It intelligently detects the underlying Linux distribution (Ubuntu, Debian, Raspberry Pi OS, DietPi) and adapts the update commands accordingly. Furthermore, it checks for `sudo` privileges dynamically.
