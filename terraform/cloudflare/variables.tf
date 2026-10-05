variable "cloudflare_account_id" {
  sensitive = true
}

variable "cloudflare_zone_id" {
  sensitive = true
}

variable "cloudflare_zone" {
  default = "livnxin.dev"
}


variable "cloudflared_replicas" {
  type        = number
  description = "Number of cloudflared replicas (for high availability, not load balancing)"
  default     = 2
}

variable "cloudflared_namespace" {
  type = string
}

variable "cloudflared_image_tag" {
  type        = string
  description = "cloudflared image tag"
  default     = "latest"
}

variable "cloudflared_labels" {
  type        = map(string)
  description = "Labels used for the selector and pod template"
  default = {
    pod = "cloudflared"
  }
}

variable "extra_labels" {
  type        = map(string)
  description = "Additional labels applied to the Deployment metadata only"
  default     = {}
}