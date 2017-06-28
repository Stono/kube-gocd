output "vpc_name" {
  value = "${google_compute_network.vpc.name}"
}

output "subnet_name" {
  value = "${google_compute_subnetwork.vpc_regional_subnet.name}"
}
