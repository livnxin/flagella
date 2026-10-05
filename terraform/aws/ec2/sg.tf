
locals {
  control_group_id = aws_security_group.talos_control_nodes.id
  worker_group_id  = aws_security_group.talos_worker_nodes.id
  cillium_group_id = aws_security_group.cillium_nodes.id
  common_id        = aws_security_group.common_secgroup.id
}

locals {
  control_self = {
    "kubelet"    = 10250
    "controller" = 10257
    "scheduler"  = 10259
    "etcd1"      = 2379
    "etcd2"      = 2380
    "kubeprism"  = 7445
    "apiserver"  = 6443
    "apid"       = 50000
  }
  worker_self = {
    "kubelet"   = 10250
    "kubeprism" = 7445
  }
  worker_to_control = {
    "trustd"         = 50001
    "kube-apiserver" = 6443
  }
  control_to_worker = {
    "kubelet"   = 10250
    "apid"      = 50000
  }
}

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

## Control Plane Security Group ##

resource "aws_vpc_security_group_egress_rule" "egress_all" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "control_self_ingress_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.control_self
}

resource "aws_vpc_security_group_egress_rule" "control_self_egress_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.control_self
}

resource "aws_vpc_security_group_ingress_rule" "control_ingress_from_worker_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.worker_to_control
}

resource "aws_vpc_security_group_egress_rule" "control_egress_to_worker_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.control_to_worker
}

resource "aws_vpc_security_group_ingress_rule" "ingress_maintainer" {
  security_group_id = local.control_group_id

  cidr_ipv4   = var.ssh_ingress_cidr
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each = {
    "kube-apiserver" = 6443
    "apid"           = 50000
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_maintainer_v6" {
  security_group_id = local.control_group_id

  cidr_ipv6   = var.ssh_ingress_cidr6
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each = {
    "kube-apiserver" = 6443
    "apid"           = 50000
  }
}

resource "aws_vpc_security_group_ingress_rule" "apid_internal" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

resource "aws_vpc_security_group_ingress_rule" "apid_auto" {
  security_group_id = local.control_group_id

  cidr_ipv4   = "${aws_instance.controlplane.public_ip}/32"
  from_port   = 50000
  ip_protocol = "tcp"
  to_port     = 50000

  description = "Talos apid to provide for Talosctl access. Based on v1.13 documentation https://docs.siderolabs.com/talos/v1.13/learn-more/talos-network-connectivity"
}

## Worker Plane Security Group ##

resource "aws_vpc_security_group_ingress_rule" "worker_self_ingress_tcp" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.worker_self
}

resource "aws_vpc_security_group_egress_rule" "worker_self_egress_tcp" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.worker_self
}

resource "aws_vpc_security_group_ingress_rule" "worker_tcp_ingress_from_control" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.control_to_worker
}

resource "aws_vpc_security_group_egress_rule" "worker_egress_to_control" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each = local.worker_to_control
}

## Common Security Group Rules ##

locals {
  common_udp = {
    "dns" = 53
    "ntp" = 123
  }
  common_tcp = {
    "dns" = 53
    "https" = 443
  }
}

resource "aws_vpc_security_group_egress_rule" "common_udp_egress" {
  security_group_id = local.common_id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = each.value
  ip_protocol = "udp"
  to_port     = each.value
  for_each = local.common_udp
}

resource "aws_vpc_security_group_egress_rule" "common_udp_egress_v6" {
  security_group_id = local.common_id

  cidr_ipv6   = "::/0"
  from_port   = each.value
  ip_protocol = "udp"
  to_port     = each.value
  for_each = local.common_udp
}

resource "aws_vpc_security_group_egress_rule" "common_tcp_egress" {
  security_group_id = local.common_id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each = local.common_tcp
}

resource "aws_vpc_security_group_egress_rule" "common_tcp_egress_v6" {
  security_group_id = local.common_id

  cidr_ipv6   = "::/0"
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each = local.common_tcp
}

## Cillium Security Group ##

resource "aws_vpc_security_group_ingress_rule" "cillium_healthcheck" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port                    = 4240
  ip_protocol                  = "tcp"
  to_port                      = 4240

  description = "Cillium Health Check. An alternative to ICMP 8/0"
}

resource "aws_vpc_security_group_ingress_rule" "cillium_vxlan" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port                    = 8472
  ip_protocol                  = "udp"
  to_port                      = 8472

  description = "Cillium VXLAN"
}

resource "aws_vpc_security_group_egress_rule" "cillium_healthcheck" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port                    = 4240
  ip_protocol                  = "tcp"
  to_port                      = 4240

  description = "Cillium Health Check. An alternative to ICMP 8/0"
}

resource "aws_vpc_security_group_egress_rule" "cillium_vxlan" {
  security_group_id = local.cillium_group_id

  referenced_security_group_id = local.cillium_group_id
  from_port                    = 8472
  ip_protocol                  = "udp"
  to_port                      = 8472

  description = "Cillium VXLAN"
}