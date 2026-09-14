# AWS Hosted MLOps Platform on Talos Linux

AWS-hosted MLOps platform that serves a California Housing price prediction model as a microservice on Kubernetes. Infrastructure is provisioned with Terraform for reproducibility. The platform runs on Talos Linux (immutable, minimal, API-driven OS designed for Kubernetes) with Cilium (eBPF networking) and Hubble (eBPF networking observability). The platform features model versioning and a model registry via KitOps OCI artifacts, least-privilege AWS Security Groups, Prometheus (metrics), OpenTelemetry (traces), Grafana Alloy (unified telemetry collection), Grafana Cloud (visualization), and Trivy (container security scanning).

## 🔐 Architectural Decisions

### Why Cilium?
- eBPF-based networking (replaces iptables, lower overhead)
- L7-aware network policies (can filter by HTTP path/method)
- Hubble provides deep network observability without sidecars
- Cluster mesh capability for future multi-cluster

### Why Talos Linux?
- Immutable OS—no SSH, no package manager, minimal attack surface
- API-driven configuration (all via `talosctl`)
- Designed specifically for Kubernetes

### Why Go for Auth?
- Mature JWT libraries (`golang-jwt`)
- Fault isolation: an auth bug cannot crash the prediction service
- Reduced attack surface: FastAPI never handles passwords

### Why FastAPI for Prediction?
- Auto-generated OpenAPI/Swagger docs
- Native async support for I/O-bound ML inference
- Pydantic validation for request schemas

### Why Grafana Alloy?
- Unified OTLP collector (metrics, logs, traces)
- First-class Grafana Cloud integration
- Lower footprint than running Prometheus + Fluent Bit + Jaeger separately

### Why Cloudflare?

### Why Kitops?

### Why instrument with prometheus and otel?

## 📊 Observability

- Alloy scrapes Prometheus metrics from Go + FastAPI pods
- Metrics forwarded to Grafana Cloud via OTLP
- [Dashboard link]
- [Screenshot]

## 🔒 Security

- RS256 JWT (asymmetric): Go signs with private key, FastAPI verifies with public key
- HttpOnly, Secure, SameSite=Strict cookies
- Cloudflare WAF + rate limiting
- Trivy scans block critical CVEs in CI
- Minimal AWS security groups

## 🚧 Limitations & Future Work

See [LIMITATIONS.md](./LIMITATIONS.md)