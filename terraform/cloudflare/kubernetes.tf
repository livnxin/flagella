resource "kubernetes_deployment_v1" "cloudflared_deployment" {
  metadata {
    name      = "cloudflared-deployment"
    namespace = var.cloudflared_namespace
    labels    = merge(var.cloudflared_labels, var.extra_labels)
  }

  spec {
    replicas = var.cloudflared_replicas

    selector {
      match_labels = var.cloudflared_labels
    }

    template {
      metadata {
        labels = var.cloudflared_labels
      }

      spec {
        security_context {
          # Allows ICMP traffic (ping, traceroute) to resources behind cloudflared
          sysctl {
            name  = "net.ipv4.ping_group_range"
            value = "65532 65532"
          }
        }

        container {
          name  = "cloudflared"
          image = "cloudflare/cloudflared:${var.cloudflared_image_tag}"

          env {
            name = "TUNNEL_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.cloudflare_secret.metadata[0].name
                key  = "token"
              }
            }
          }

          command = [
            "cloudflared",
            "tunnel",
            "--no-autoupdate",
            "--loglevel",
            "info",
            "--output",
            "json",
            "--metrics",
            "0.0.0.0:2000",
            "run",
          ]

          liveness_probe {
            http_get {
              path = "/ready"
              port = 2000
            }
            failure_threshold     = 1
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_secret_v1" "cloudflare_secret" {
  metadata {
    name = "cloudflare-tunnel-secret"
    namespace = var.cloudflared_namespace
  }

  data = {
    token = data.cloudflare_zero_trust_tunnel_cloudflared_token.cloudflared_tunnel_token.token
  }

  type = "opaque"
}