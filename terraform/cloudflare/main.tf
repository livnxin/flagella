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

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cloudflared_tunnel_config" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id
  account_id = var.cloudflare_account_id
  config = {
    ingress = [
      {
        hostname = "flagella.${var.cloudflare_zone}"
        service  = "http://cilium-ingress.kube-system.svc.cluster.local:80"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}

resource "cloudflare_dns_record" "cname" {
  zone_id = var.cloudflare_zone_id
  name    = "flagella"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cloudflared_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
