terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

resource "kubernetes_secret_v1" "cloudflare_secret" {
  metadata {
    name = "cloudflare-tunnel-secret"
  }

  data = {
    token = data.cloudflare_zero_trust_tunnel_cloudflared_token.cloudflared_tunnel_token.token
  }

  type = "kubernetes.io/basic-auth"
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cloudflared_tunnel_token" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cloudflared_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "service"
  config_src = "cloudflare"
}

## TODO: PLaceholder, will fix later

# resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cloudflared_tunnel_config" {
#   tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
#   account_id = var.cloudflare_account_id
#   config = {
#     ingress = [
#       {
#         hostname = "http_app.${var.cloudflare_zone}"
#         service  = "http://httpbin:80"
#       },
#       {
#         service = "http_status:404"
#       }
#     ]
#   }
# }

# resource "cloudflare_dns_record" "http_app" {
#   zone_id = var.cloudflare_zone_id
#   name    = "http_app"
#   content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }
