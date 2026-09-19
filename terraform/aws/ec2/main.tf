resource "aws_instance" "controlplane" {
  ami                    = var.talos_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.control_subnet_id
  key_name               = var.ssh_key_name
  vpc_security_group_ids = [local.control_group_id, local.cillium_group_id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-controlplane"
    Role = "controlplane"
  }
}

resource "aws_autoscaling_group" "talos_workers" {
  name = "talos-workers"

  min_size         = var.autoscaling_min_size
  desired_capacity = var.autoscaling_desired_capacity
  max_size         = var.autoscaling_max_size

  vpc_zone_identifier = [var.worker_subnet_id]

  capacity_rebalance = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.autoscaling_base_on_demand
      on_demand_percentage_above_base_capacity = var.autoscaling_on_demand_percentage
      spot_allocation_strategy                 = "price-capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.talos_worker.id
        version            = "$Latest"
      }

      override {
        instance_type = "t3.small"
      }
    }
  }
}

resource "aws_launch_template" "talos_worker" {
  name_prefix = "talos-worker-"

  image_id = var.talos_ami_id

  user_data = base64encode(
    var.talos_worker_config
  )

  instance_type = "t3.small"

  network_interfaces {
    security_groups = [
      local.control_group_id, local.cillium_group_id
    ]
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "talos-worker"
    }
  }
}
