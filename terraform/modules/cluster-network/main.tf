resource "google_compute_network" "vpc" {
  name    = "${var.stack}-${var.env}-vpc"
}

resource "google_compute_subnetwork" "vpc_regional_subnet" {
  name          = "${var.stack}-${var.env}-${var.subnet_region}"
  network       = "${google_compute_network.vpc.name}"
  region        = "${var.subnet_region}"
  ip_cidr_range = "${var.subnet_range}"
}

resource "google_compute_firewall" "standard-ports" {
   name    = "${var.stack}-${var.env}-standard-ports"
  network = "${google_compute_network.vpc.name}"

  # Im not sure if this is used for monitoring, need to check
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Put the IP CIDR ranges that should be able to SSH
  # Really, you shouldn't need to SSH on GKE, ever
  source_ranges = []
}
