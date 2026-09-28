resource "kubernetes_secret_v1" "cloudflare_secret" {
  metadata {
    name = "cloudflare-tunnel-secret"
  }

  data = {
    token = data.cloudflare_zero_trust_tunnel_cloudflared_token.cloudflared_token.token
  }

  type = "kubernetes.io/basic-auth"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cloudflared_tunnel_token" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cloudflared_tunnel" {
  account_id = var.account_id
  name       = "blog"
  config_src = "cloudflare"
}

