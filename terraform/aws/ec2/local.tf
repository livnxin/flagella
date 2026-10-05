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
    "kubelet" = 10250
    "apid"    = 50000
  }
}

locals {
  common_udp = {
    "dns" = 53
    "ntp" = 123
  }
  common_tcp = {
    "dns"   = 53
    "https" = 443
  }
}
