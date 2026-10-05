
resource "aws_vpc_security_group_egress_rule" "common_udp_egress" {
  security_group_id = local.common_id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = each.value
  ip_protocol = "udp"
  to_port     = each.value
  for_each    = local.common_udp
}

resource "aws_vpc_security_group_egress_rule" "common_udp_egress_v6" {
  security_group_id = local.common_id

  cidr_ipv6   = "::/0"
  from_port   = each.value
  ip_protocol = "udp"
  to_port     = each.value
  for_each    = local.common_udp
}

resource "aws_vpc_security_group_egress_rule" "common_tcp_egress" {
  security_group_id = local.common_id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each    = local.common_tcp
}

resource "aws_vpc_security_group_egress_rule" "common_tcp_egress_v6" {
  security_group_id = local.common_id

  cidr_ipv6   = "::/0"
  from_port   = each.value
  ip_protocol = "tcp"
  to_port     = each.value
  for_each    = local.common_tcp
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