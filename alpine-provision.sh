#!/bin/sh
set -e

# === Configuration ===
USERNAME="alpineuser"
USERPASS="changeme"
ROOTPASS="rootpassword"

# === User creation ===
if ! id "$USERNAME" >/dev/null 2>&1; then
    echo "Creating user $USERNAME"
    adduser -D "$USERNAME"
    echo "$USERNAME:$USERPASS" | chpasswd
else
    echo "User $USERNAME already exists"
fi

# === Set root password ===
echo "root:$ROOTPASS" | chpasswd

# === SSH hardening ===
SSHD_CONFIG="/etc/ssh/sshd_config"

# Disable password authentication
if grep -q "^PasswordAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' "$SSHD_CONFIG"
else
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
fi

# Enable public key authentication
if grep -q "^PubkeyAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^PubkeyAuthentication.*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
else
    echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
fi

# Disable root login with password
if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin prohibit-password/' "$SSHD_CONFIG"
else
    echo "PermitRootLogin prohibit-password" >> "$SSHD_CONFIG"
fi

# Restart SSH service
rc-service sshd restart

echo "Provisioning complete."