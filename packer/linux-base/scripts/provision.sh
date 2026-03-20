#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  openssh-server \
  python3 \
  sudo \
  curl \
  ca-certificates \
  jq \
  vim-tiny \
  net-tools \
  iproute2

sudo systemctl enable systemd-timesyncd.service
sudo systemctl restart systemd-timesyncd.service

# Ensure OpenSSH is enabled for first boot access.
sudo systemctl enable ssh.service

# Remove machine-unique data to improve template reuse and reproducibility.
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reduce artifact variability by cleaning transient package metadata.
sudo apt-get autoremove -y
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
