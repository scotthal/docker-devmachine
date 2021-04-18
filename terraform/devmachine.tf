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
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}