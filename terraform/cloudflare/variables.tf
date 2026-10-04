variable "cloudflare_account_id" {
  sensitive = true
}

variable "cloudflare_zone_id" {
  sensitive = true
}

variable "cloudflare_zone" {
  default = "livnxin.dev"
}