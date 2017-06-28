variable "stack" {
  description = "The name for the stack, used for prefixing"
}

variable "env" {
  description = "The environment you are creating the cluster for"
}

variable "subnet_range" {
  description = "The ip range for the subnet which kubernetes machines will be created in"
}

variable "container_cidr_range" {
  description = "The CIDR range the docker containers will be DHCPd from"
}

variable "cluster_username" {
  description = "The username for logging into kubernetes ui"
  default = "admin" 
}

variable "cluster_password" {
  description = "The password for logging into kubernetes ui"
}
