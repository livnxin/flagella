resource "kubernetes_secret_v1" "cloudflare_secret" {
  metadata {
    name = "cloudflare-tunnel-secret"
  }

  data = {
    token = "admin"
  }

  type = "kubernetes.io/basic-auth"
}
