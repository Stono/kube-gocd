provider "google" {
  credentials  = ""
  project      = "peopledata-product-team"
  region       = "europe-west1"
}

# Uncomment this for remote state storage
# You'll need to create the bucket first
#terraform {
#  backend "gcs" {
#    bucket = "your-gcp-bucket-name"
#    path   = "terraform.tfstate"
#    project = "your-project-name"
#  }
#}

module "container" {
  source = "../modules/container"
  env = "dev"
	stack = "${var.stack}"
  subnet_range = "10.34.96.0/24"								# The IP range for the kubernetes VMs
  container_cidr_range = "10.37.64.0/19"				# The IP range for the containers
  cluster_password = "${var.cluster_password}"  # The password for the kubernetes UI
}
