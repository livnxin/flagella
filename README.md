Goal of this project

This project is intended to be an MLOps project hosted in K8S as microservice

Architectural Decision

- Why cillium? layer 7 aware network policy, cluster mesh, integration with Hubble, eBPF networking that is better than Iptables

- Why talos? Immutable linux distro designed for Kubernetes

- Why Clickhouse? Because its an OLAP database with BASE instead of ACID and I believe that BASE is more suitable for the scalability of the type of data I am handling

- Why alloy? Because Alloy is a OTLP Collector that integrates well with the rest of grafana stack and unify the various telemtry collector into one application, thus lowering application footprint