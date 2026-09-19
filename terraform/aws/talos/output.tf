output "talos_worker_config" {
    value = data.talos_machine_configuration.worker.machine_configuration
}