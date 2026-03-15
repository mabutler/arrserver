#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v ansible-playbook &>/dev/null; then
    echo "==> Initializing pacman keyring..."
    pacman-key --init
    pacman-key --populate archlinux

    echo "==> Updating keyring and system..."
    pacman -Sy --noconfirm archlinux-keyring
    pacman -Syu --noconfirm

    echo "==> Installing Ansible..."
    pacman -S --noconfirm ansible

    echo "==> Installing Ansible collections..."
    ansible-galaxy collection install community.general community.docker

    RUNNING_KERNEL=$(uname -r)
    INSTALLED_KERNEL=$(ls /lib/modules/ | sort -V | tail -1)
    if [[ "$RUNNING_KERNEL" != "$INSTALLED_KERNEL" ]]; then
        echo ""
        echo "==> Kernel updated ($RUNNING_KERNEL -> $INSTALLED_KERNEL). Rebooting..."
        echo "==> After reboot, re-run: sudo bash $REPO_DIR/scripts/bootstrap.sh"
        reboot
    fi
else
    echo "==> Ansible already installed, skipping..."
fi

SECRETS_FILE="$REPO_DIR/ansible/secrets.yml"
if [[ ! -f "$SECRETS_FILE" ]]; then
    echo ""
    echo "==> Enter secrets (input will be hidden):"
    read -rsp "    Tailscale auth key: " tailscale_auth_key < /dev/tty
    echo ""
    cat > "$SECRETS_FILE" <<EOF
---
tailscale_auth_key: "${tailscale_auth_key}"
EOF
    echo "==> secrets.yml written."
fi

echo "==> Running bootstrap playbook..."
ansible-playbook "$REPO_DIR/ansible/playbooks/bootstrap.yml" \
    -i "$REPO_DIR/ansible/inventory/hosts.yml" \
    --ask-become-pass

echo ""
echo "==> Bootstrap complete. loki is ready."
