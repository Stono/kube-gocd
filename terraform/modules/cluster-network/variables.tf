variable "stack" {
  description = "The name for the stack, used for prefixing"
}

variable "env" {
  description = "The environment you are creating the cluster for"
}

variable "subnet_range" {
  description = "The ip range for the subnet which kubernetes machines will be created in"
}

variable "subnet_region" {
  description = "The subnet region"
}
