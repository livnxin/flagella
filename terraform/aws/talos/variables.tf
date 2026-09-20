variable "controlplane_ip" {
  type = string
}

variable "controlplane_private_ip" {
  type = string
}

variable "cluster_name" {
  default = "aws-cluster"
}

output "talos_client" {
  value = data.talos_client_configuration.this.talos_config
}