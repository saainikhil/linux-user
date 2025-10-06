#!/bin/bash
# ================================================================
# Script Name: create_users.sh
# Description: Automates user creation, group setup, and password management
# Author: Petnikoti Sai Nikhil
# Date: 2025-10-05
# ================================================================

LOG_FILE="/var/log/user_management.log"
SECURE_DIR="/var/secure"
PASSWORD_FILE="$SECURE_DIR/user_passwords.csv"

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Ensure input file is provided
if [[ -z "$1" ]]; then
    echo "Usage: bash $0 <user_list.txt>"
    exit 1
fi

INPUT_FILE="$1"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Input file not found: $INPUT_FILE"
    exit 1
fi

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$SECURE_DIR"
touch "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

while IFS=';' read -r username groups; do
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs | tr -d ' ')

    [[ -z "$username" ]] && continue

    echo "Processing user: $username" | tee -a "$LOG_FILE"

    # Create personal group
    if ! getent group "$username" > /dev/null; then
        groupadd "$username"
        echo "Created group: $username" >> "$LOG_FILE"
    else
        echo "⚠️ Group $username already exists." >> "$LOG_FILE"
    fi

    # Create user
    if ! id "$username" &>/dev/null; then
        useradd -m -g "$username" "$username"
        echo "Created user: $username" >> "$LOG_FILE"
    else
        echo "⚠️ User $username already exists." >> "$LOG_FILE"
    fi

    # Assign additional groups
    if [[ -n "$groups" ]]; then
        IFS=',' read -ra extra_groups <<< "$groups"
        for grp in "${extra_groups[@]}"; do
            if ! getent group "$grp" > /dev/null; then
                groupadd "$grp"
                echo "Created group: $grp" >> "$LOG_FILE"
            fi
            usermod -aG "$grp" "$username"
            echo "Added $username to $grp" >> "$LOG_FILE"
        done
    fi

    # Generate random password
    password=$(openssl rand -base64 12)
    echo "$username,$password" >> "$PASSWORD_FILE"
    echo "$username:$password" | chpasswd
    echo "Password set for $username" >> "$LOG_FILE"

    # Secure home directory
    chmod 700 "/home/$username"
    chown "$username:$username" "/home/$username"
    echo "Secured home for $username" >> "$LOG_FILE"
    echo "---------------------------------------------" >> "$LOG_FILE"

done < "$INPUT_FILE"

echo " User creation process completed successfully!"
echo "Logs → $LOG_FILE"
echo "Passwords → $PASSWORD_FILE (root-only access)"

