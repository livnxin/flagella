terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
  }


}

provider "aws" {
}

module "talos" {
  source = "./aws/talos"

  controlplane_ip = module.ec2.controlplane_public_ip
  controlplane_private_ip = module.ec2.controlplane_private_ip

}

module "vpc" {
  source = "./aws/vpc"

  aws_vpc_cidr = var.aws_vpc_cidr
  environment  = var.aws_environment
}

module "ec2" {
  source = "./aws/ec2"

  environment       = var.aws_environment
  vpc_id            = module.vpc.vpc_id
  control_subnet_id = module.vpc.control_subnet_id
  worker_subnet_id  = module.vpc.worker_subnet_id
  ssh_ingress_cidr  = var.ssh_ingress_cidr
  ssh_ingress_cidr6 = var.ssh_ingress_cidr6

  instance_type = var.aws_instance_type
  talos_ami_id  = var.talos_ami_id
  ssh_key_name  = var.ssh_key_name

  talos_worker_config = module.talos.talos_worker_config

  autoscaling_on_demand_percentage = var.autoscaling_on_demand_percentage
  autoscaling_base_on_demand       = var.autoscaling_base_on_demand

  autoscaling_min_size         = var.autoscaling_min_size
  autoscaling_max_size         = var.autoscaling_max_size
  autoscaling_desired_capacity = var.autoscaling_desired_capacity

  depends_on = [module.vpc]
}

output "talos_client" {
  value     = module.talos.talos_client
  sensitive = true
}

output "kubeconfig" {
  value = module.talos.kubeconfig
  sensitive = true
}