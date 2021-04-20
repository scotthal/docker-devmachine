terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.64.0"
    }
  }
}

provider "google" {
  credentials = file("credential.json")
  project     = "scotthal-mess-311116"
  region      = "us-west1"
  zone        = "us-west1-c"
}

resource "google_compute_instance" "dev" {
  name                      = "dev"
  machine_type              = "e2-medium"
  allow_stopping_for_update = true
  labels                    = { purpose = "scotthal-dev" }

  scheduling {
    automatic_restart = false
    preemptible       = true
  }

  boot_disk {
    initialize_params {
      size = 30
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
      ssh-keys = "scotthal:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiNxqnxBCK0ElR0ac0RcTW6wbXB58/hUqyDVGxNEN4xj3jkCLPVY1IhdS8uP7IEN1uOJ8IR/Wj+8R+ikxvF2nKEsre1UX6ZC5P73HdpP9DsXxFyRlk0F4E7P/P25j6HpjmlRP0E66sJ8EOvySMcdkwOEQMxsGducVWhAKIxvO7NhcczpfYiyqm3Rg5FAzxu+ANCjzAn/GVpPiijyN+kEibNNeHMcACwBKTuRAHuXGNOSTTlGAdbAk2iDKE7zYi8CoaMbr7UPInHwIIYyX+c1dw4PK+CgMnvVWmTrdtaSTMrhQ8oJ5etQqSrDe4ifOYi5fD/CfwoaTd+9+kDatLXhvLI/grl2bdiabpQad54Z6vqoZoZHAVCXk1k8ARKN9rVOKFO+twFnIgn4DlRDLAsIM83qe1+F5bExbQrTE9zTnUn+KjhhF4xorjv/OwJtqeIt/CJLW0vaRPvSzBrjjRMcpHPK5BR6AtUn9f6KuKGrpLPagtJUZ27BBPCDo01QfpDsefRXeW8YBwzNx4VLsqJGxB3zpOXpBfMZ80UU/4X810Vn2J52d20z/xKx1WqoeDuRDNt8mZVAUiA0XjBbJiHEN0Je9tToYQlcUKccYQ0/ovOHdlbKKsIn06YoxqhPZMVr1Xxe/aoBbCPZM30nqodesA+Df4esFnm/GUdzKfcIY6MQ== scotthal"
  }
  metadata_startup_script = "${file("${path.module}/../setup.sh")}"
}