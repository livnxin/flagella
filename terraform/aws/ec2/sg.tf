resource "aws_security_group" "common_secgroup" {
  name_prefix = "${var.environment}-common"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-common-sg"
  }
}

resource "aws_security_group" "talos_control_nodes" {
  name_prefix = "${var.environment}-talos-control"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-control-talos-sg"
  }
}

resource "aws_security_group" "talos_worker_nodes" {
  name_prefix = "${var.environment}-talos-worker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-worker-talos-sg"
  }
}

resource "aws_security_group" "cillium_nodes" {
  name_prefix = "${var.environment}-cillium"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-cillium-sg"
  }
}