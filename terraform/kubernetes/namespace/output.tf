output "cloudflare_namespace" {
  value = kubernetes_namespace_v1.cloudflare.metadata[0].name
}