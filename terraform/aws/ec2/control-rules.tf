resource "aws_vpc_security_group_ingress_rule" "control_self_ingress_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.control_self
}

resource "aws_vpc_security_group_egress_rule" "control_self_egress_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.control_self
}

resource "aws_vpc_security_group_ingress_rule" "control_ingress_from_worker_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.worker_to_control
}

resource "aws_vpc_security_group_egress_rule" "control_egress_to_worker_tcpv4" {
  security_group_id = local.control_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.control_to_worker
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