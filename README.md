Sure! Here’s a clean, professional **README.md** for your project without emojis:

---

# Linux User Management Automation Script

## Overview

This project provides a Bash script (`create_users.sh`) to automate the creation and management of Linux users. It is designed for system administrators or DevOps engineers to efficiently onboard multiple users while ensuring security, proper group assignments, and logging.

The script reads a list of usernames and groups from an input file and performs all necessary tasks, including creating users and groups, generating secure passwords, setting home directory permissions, and logging actions.

---

## Features

* Reads usernames and group assignments from a text file (`users.txt`).
* Creates each user with:

  * A personal primary group (same as username).
  * Supplementary groups as specified in the file.
  * A home directory with secure permissions (750).
* Generates a random password for each user.
* Stores passwords securely in `/var/secure/user_passwords.csv` (root-only access).
* Logs all actions to `/var/log/user_management.log`.
* Handles existing users or groups gracefully, preventing script failure.
* Ensures proper ownership and permissions for all directories and files.

---

## Input File Format

The input file should have the following format:

```
username; group1,group2,group3
```

* `username` — the name of the user to create.
* `group1,group2,group3` — comma-separated list of supplementary groups.
* Whitespace around names is ignored.

**Example:**

```
light; sudo,dev,www-data
idimma; sudo
mayowa; dev,www-data
```

---

## Prerequisites

* Linux system (Ubuntu/Debian recommended)
* Bash shell
* Root privileges

---

## Usage

1. Make the script executable:

```bash
sudo chmod +x create_users.sh
```

2. Run the script with the input file as an argument:

```bash
sudo ./create_users.sh users.txt
```

3. Verify the results:

* Log file: `/var/log/user_management.log`
* Passwords file: `/var/secure/user_passwords.csv` (readable only by root)

---

## Security Considerations

* Passwords are generated using `openssl rand -base64 12` to ensure strong randomness.
* Home directories are created with `750` permissions to restrict access.
* Password file is only readable by root (`chmod 600`).
* Logging allows for auditing and tracking of user creation activities.

---

