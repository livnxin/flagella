resource "aws_vpc_security_group_egress_rule" "cloudflareregion_1" {
  security_group_id = var.common_secgroup
  from_port                    = 7844
  ip_protocol                  = "tcp"
  to_port                      = 7844
  cidr_ipv4 = "198.41.192.0/24"
}

resource "aws_vpc_security_group_egress_rule" "cloudflare_region1_quic" {
  security_group_id = var.common_secgroup
  from_port                    = 7844
  ip_protocol                  = "udp"
  to_port                      = 7844
  cidr_ipv4 = "198.41.192.0/24"
}

resource "aws_vpc_security_group_egress_rule" "cloudflareregion_2" {
  security_group_id = var.common_secgroup
  from_port                    = 7844
  ip_protocol                  = "tcp"
  to_port                      = 7844
  cidr_ipv4 = "198.41.200.0/24"
}

resource "aws_vpc_security_group_egress_rule" "cloudflare_region2_quic" {
  security_group_id = var.common_secgroup
  from_port                    = 7844
  ip_protocol                  = "udp"
  to_port                      = 7844
  cidr_ipv4 = "198.41.200.0/24"
}