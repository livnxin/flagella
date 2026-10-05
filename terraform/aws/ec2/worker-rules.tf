
resource "aws_vpc_security_group_ingress_rule" "worker_self_ingress_tcp" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.worker_self
}

resource "aws_vpc_security_group_egress_rule" "worker_self_egress_tcp" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.worker_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.worker_self
}

resource "aws_vpc_security_group_ingress_rule" "worker_tcp_ingress_from_control" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.control_to_worker
}

resource "aws_vpc_security_group_egress_rule" "worker_egress_to_control" {
  security_group_id = local.worker_group_id

  referenced_security_group_id = local.control_group_id
  from_port                    = each.value
  ip_protocol                  = "tcp"
  to_port                      = each.value
  for_each                     = local.worker_to_control
}