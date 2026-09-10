MarketPulse learning goals

Primary goal:
Learn Terraform → Linux/networking → Kubernetes administration → DevOps tooling.
Do not optimize for generating the project as quickly as possible.

Current phase:
Terraform / GCP infrastructure.

Architecture:
- GCP
- custom VPC
- custom subnet
- self-managed Kubernetes via kubeadm
- 1 control plane
- 2 workers
- Cilium CNI
- Kafka via Strimzi
- PostgreSQL inside Kubernetes
- Redis
- Python producer/consumers
- ArgoCD
- Prometheus/Grafana
- Vault later

Terraform principles:
- User should implement things themselves.
- Explain problems rather than automatically rewriting code.
- Avoid modules until fundamentals are understood.
- Prefer explicit resources while learning.
- Terraform manages GCP infrastructure.
- Kubernetes manifests manage workloads/platform components.

Current VM design:
- control-plane: e2-medium
- worker-1: e2-standard-2
- worker-2: e2-standard-2
- Rocky Linux 10
- 30 GB boot disks
- private subnet
- node IP forwarding
...