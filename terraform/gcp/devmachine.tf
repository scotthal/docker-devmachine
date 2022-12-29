terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.15.0"
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
  machine_type              = "e2-standard-2"
  allow_stopping_for_update = true
  labels                    = { purpose = "scotthal-dev" }

  scheduling {
    automatic_restart = false
    preemptible       = true
  }

  boot_disk {
    initialize_params {
      size  = 30
      image = "ubuntu-os-cloud/ubuntu-2210-amd64"
    }
  }

  network_interface {
    network = google_compute_network.dev_network.self_link
    access_config {}
  }

  metadata = {
    ssh-keys = "scotthal:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/1WmB/5c3gd/3R1gAArZb8rdGKIXH+6K3YCShG1gilhc8yLaaBzVCf1ny7LdCf33Rs2QnSGsDEDpN/lJ/TLxA909WabvUgrrkeYwOkYrv++wUOsviWWQdHYFElc8p9MToLWz/Av2g97mqMaH69CD9QJXGstOYDm1QAbPy17WGYfuCRgRJVqyWy28vi84Ysg1UqPW/E+HiWCVIO2R4y3xfNKM8b+L6DAM0XcKBj2T+fJsBFK9e8UyMGpM/XVPoPS4ZPyjoYex4hYimD0k3xz7LJRgHz6mRRKyaAoIxVi6pxVtWEOeQtIQwnBh54hK1ORk9NtDA8FyjrQloZRNriLnCrhWj5aSl7jAI9aI4Y/IR+rU63kYIFGVVcOeVRR25qeSYQmlCHMoA8pTtzN5g3DNH2RmHXUTMkHg+fCnDZ3L1R5CbPgokvLwvBAm6qkWYEzzcl/w587bN7JAx5+uvky1HnEiDVktzL7A0sJF9X3AD5yrkZnpkqF6Gs95jqaXDn0MCQ+Ub5vAWElqHY9LTHRynFa+KBv9IC2uWAfm3RNRmekJfLWRJqQ9IZT8aqvV/n43PcW0jaLLPvXKFBjXYM50909Mi3I4GgcWmJQp9BNuQ8JdveuNDdNnevAHrtQdrjuQIOPsaNLrJbIAxtnJf1DPq19quMJg8R1xSwPn3l6sYvQ== scotthal@cs-25160505235-default-boost-cc88k"
  }
  metadata_startup_script = file("${path.module}/../../setup.sh")
}

resource "google_compute_network" "dev_network" {
  name                    = "dev-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "dev_firewall" {
  name    = "dev-firewall"
  network = google_compute_network.dev_network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "8000-8999"]
  }

  source_ranges = ["0.0.0.0/0"]
}
