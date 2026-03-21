#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Initializing pacman keyring..."
pacman-key --init
pacman-key --populate archlinux

echo "==> Updating keyring and system..."
pacman -Sy --noconfirm --needed archlinux-keyring
pacman -Syu --noconfirm

echo "==> Installing Ansible..."
pacman -S --noconfirm --needed ansible

RUNNING_KERNEL=$(uname -r)
INSTALLED_KERNEL=$(ls /lib/modules/ | sort -V | tail -1)
if [[ "$RUNNING_KERNEL" != "$INSTALLED_KERNEL" ]]; then
    echo ""
    echo "==> Kernel updated ($RUNNING_KERNEL -> $INSTALLED_KERNEL). Rebooting..."
    echo "==> After reboot, re-run: sudo bash $REPO_DIR/scripts/bootstrap.sh"
    reboot
fi

echo "==> Installing Ansible collections..."
ansible-galaxy collection install community.general community.docker

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

ALL_VARS="$REPO_DIR/ansible/inventory/group_vars/all.yml"
SERVER_USER=$(python3 -c "import yaml; print(yaml.safe_load(open('$ALL_VARS'))['server_user'])" 2>/dev/null)
SYNC_KEY_PATH="/home/${SERVER_USER}/.ssh/id_ed25519_sync"
SYNC_REMOTE_HOST=$(python3 -c "import yaml; print(yaml.safe_load(open('$ALL_VARS'))['sync_remote_host'])" 2>/dev/null)
SYNC_REMOTE_USER=$(python3 -c "import yaml; print(yaml.safe_load(open('$ALL_VARS'))['sync_remote_user'])" 2>/dev/null)

if [[ ! -f "$SYNC_KEY_PATH" ]]; then
    if [[ "$SYNC_REMOTE_HOST" == "PLACEHOLDER" || "$SYNC_REMOTE_USER" == "PLACEHOLDER" ]]; then
        echo ""
        echo "==> ERROR: Fill in sync_remote_host and sync_remote_user in all.yml before running bootstrap."
        exit 1
    fi
    echo ""
    echo "==> Generating SSH keypair for sync..."
    sudo -u mbutler ssh-keygen -t ed25519 -f "$SYNC_KEY_PATH" -N ""
    echo ""
    echo "==> Installing SSH key on remote download server (${SYNC_REMOTE_USER}@${SYNC_REMOTE_HOST})..."
    echo "    Enter the remote server password when prompted."
    sudo -u mbutler ssh-copy-id -i "${SYNC_KEY_PATH}.pub" "${SYNC_REMOTE_USER}@${SYNC_REMOTE_HOST}"
    echo "==> SSH key installed. Password will not be needed again."
fi

echo "==> Running bootstrap playbook..."
ansible-playbook "$REPO_DIR/ansible/playbooks/bootstrap.yml" \
    -i "$REPO_DIR/ansible/inventory/hosts.yml" \
    --ask-become-pass

echo "==> Deploying arr stack..."
ansible-playbook "$REPO_DIR/ansible/playbooks/arr.yml" \
    -i "$REPO_DIR/ansible/inventory/hosts.yml" \
    --ask-become-pass

echo ""
echo "==> Bootstrap complete. loki is ready."
