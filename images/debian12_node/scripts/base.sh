#!/usr/bin/env bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive

sudo apt update
sudo apt -y upgrade

sudo apt install -y \
  ca-certificates \
  curl \
  vim \
  jq \
  net-tools \
  iproute2 \
  htop \
  bash-completion \
  gnupg

sudo systemctl disable --now apt-daily.timer apt-daily-upgrade.timer || true

sudo apt autoremove -y
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
