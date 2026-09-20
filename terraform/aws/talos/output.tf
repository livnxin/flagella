output "talos_worker_config" {
  value = data.talos_machine_configuration.worker.machine_configuration
}

output "kubeconfig" {
  value = data.talos_cluster_kubeconfig.this.kubeconfig_raw
}