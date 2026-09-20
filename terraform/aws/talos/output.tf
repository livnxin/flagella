output "talos_worker_config" {
  value = data.talos_machine_configuration.worker.machine_configuration
}

output "kubeconfig" {
  value = data.talos_cluster_kubeconfig.this.kubeconfig_raw
}

output "cluster_host" {
  value = local.cluster_endpoint
}

output "cluster_kubeconfig" {
  value = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration
}