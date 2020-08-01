terraform {
  required_version = ">= 0.12"
  required_providers {
    esxi = {
      version = "~> 1.7"
    }
  }
}

provider "esxi" {
  esxi_hostname      = var.esxi_host
  esxi_hostport      = "22"
  esxi_hostssl       = "443"
  esxi_username      = var.esxi_username
  esxi_password      = var.esxi_password
}

resource "esxi_guest" "ocp4-helpernode" {
  guest_name     = "ocp4-helpernode"
  numvcpus       = "4"
  memsize        = "8192"  # in Mb
  boot_disk_size = "200" # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  guestos        = "centos-64"
  power          = "off"
  virthwver      = "13"

  network_interfaces {
    mac_address     = "00:50:56:01:01:0B"
    virtual_network = var.home_network
  }
}

resource "esxi_guest" "ocp4-machines" {
  for_each = {
    ocp4-bootstrap = "00:50:56:01:01:0C"
    ocp4-control-plane-1 = "00:50:56:01:01:0D"
    ocp4-control-plane-2 = "00:50:56:01:01:0E"
    ocp4-control-plane-3 = "00:50:56:01:01:0F"
    ocp4-compute-1 = "00:50:56:01:01:10"
    ocp4-compute-2 = "00:50:56:01:01:11"
  }
  guest_name     = each.key
  numvcpus       = "4"
  memsize        = "16384"  # in Mb
  boot_disk_size = "120" # in Gb
  boot_disk_type = "thin"
  disk_store     = var.datastore
  guestos        = "fedora-64"
  power          = "off"
  virthwver      = "13"

  network_interfaces {
    mac_address     = each.value
    virtual_network = var.home_network
  }
}
