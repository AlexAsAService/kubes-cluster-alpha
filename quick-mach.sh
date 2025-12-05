#!/bin/bash

sudo qemu-system-x86_64 -drive file="$IMAGE_PATH",if=virtio \
  -m 4096 \
  -smp 4 \
  -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
  -nographic
