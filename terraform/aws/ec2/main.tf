resource "aws_instance" "controlplane" {
  ami                    = var.talos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.control_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [local.control_group_id]

  root_block_device {
    volume_size = 20 
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-controlplane"
    Role = "controlplane"
  }
}

resource "aws_instance" "worker" {
  count = var.worker_count

  ami                    = var.talos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.worker_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [local.worker_group_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "hibernate"
      spot_instance_type = "persistent"
    }
  }

  tags = {
    Name = "${var.environment}-worker-${count.index}"
    Role = "worker"
  }
}
