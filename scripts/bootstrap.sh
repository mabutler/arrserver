#!/bin/bash
set -e

REPO_URL="https://github.com/mabutler/arrserver"
REPO_DIR="/opt/arrserver"

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
    ansible-galaxy collection install community.general
else
    echo "==> Ansible already installed, skipping..."
fi

if [ -d "$REPO_DIR" ]; then
    echo "==> Removing existing $REPO_DIR..."
    rm -rf "$REPO_DIR"
fi

echo "==> Cloning repo to $REPO_DIR..."
git clone "$REPO_URL" "$REPO_DIR"

echo ""
echo "==> Before continuing, fill in your secrets:"
echo "    cp $REPO_DIR/ansible/secrets.yml.example $REPO_DIR/ansible/secrets.yml"
echo "    vim $REPO_DIR/ansible/secrets.yml"
echo ""
read -rp "Press Enter when secrets.yml is ready..."

echo "==> Running bootstrap playbook..."
ansible-playbook "$REPO_DIR/ansible/playbooks/bootstrap.yml" --ask-become-pass

echo ""
echo "==> Bootstrap complete. loki is ready."
