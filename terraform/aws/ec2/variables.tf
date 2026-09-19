variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "control_subnet_id" {
  type = string
}

variable "worker_subnet_id" {
  type = string
}

variable "ssh_ingress_cidr" {
  type = string
}

variable "ssh_ingress_cidr6" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "talos_ami_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "autoscaling_min_size" {
  type    = number
  default = 1
}

variable "autoscaling_max_size" {
  type    = number
  default = 2
}

variable "autoscaling_desired_capacity" {
  type    = number
  default = 1
}

variable "autoscaling_base_on_demand" {
  type    = number
  default = 0
}

variable "autoscaling_on_demand_percentage" {
  type    = number
  default = 0
}

variable "talos_worker_config" {
}