packer {
  required_version = ">= 1.9.0"

  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "debian_version" {
  type    = string
  default = "12"
}

variable "image_url" {
  type    = string
  default = "https://cdimage.debian.org/images/cloud/bookworm/20251112-2294/debian-12-generic-amd64-20251112-2294.qcow2"
}

variable "image_sha" {
  type    = string
  default = "5da221d8f7434ee86145e78a2c60ca45eb4ef8296535e04f6f333193225792aa8ceee3df6aea2b4ee72d6793f7312308a8b0c6a1c7ed4c7c730fa7bda1bc665f"
}

variable "ssh_username" {
  type    = string
  default = "debian"
}

variable "ssh_private_key_file" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "disk_size" {
  type = string
  default = "20G"
}

source "qemu" "debian12" {
  iso_url      = var.image_url
  iso_checksum = var.image_sha
  disk_image   = true

  communicator         = "ssh"
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "1m"

  headless       = true
  accelerator    = "kvm"
  disk_interface = "virtio"
  format         = "qcow2"
  disk_size      = var.disk_size

  cd_files = [
    "cloud-init/meta-data",
  ]

  cd_content = {
    "user-data" = templatefile("cloud-init/user-data", {
      runtime_pubkey = var.ssh_public_key
    }),
  }

  cd_label         = "CIDATA"
  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "debian12-k8s-base"
  sources = ["source.qemu.debian12"]

  provisioner "shell" {
    script = "scripts/base.sh"
  }

  provisioner "shell" {
    script = "scripts/k8s-prereqs.sh"
  }

  post-processor "compress" {
    output = "output/debian-k8s-base.qcow2.gz"
  }
}