# Terraform-ECR-EKS-Deploy# EKS Application with Prometheus & Grafana Monitoring + Argo CD GitOps



**Infrastructure as Code for EKS with Prometheus, Grafana, and Argo CD GitOps**This repository contains Terraform configurations for deploying a containerized application to Amazon EKS with:

- Prometheus & Grafana monitoring

---- Argo CD for GitOps-based continuous deployment



## 📋 Quick Start## 🚀 Argo CD GitOps Deployment



### Prerequisites### How It Works

- Terraform >= 1.6

- AWS CLI configured with credentialsArgo CD automatically synchronizes your Kubernetes deployments with this Git repository. When you update the manifests in `manifests/production/`, Argo CD will:

- kubectl installed1. Detect the change

- Docker (for building images)2. Compare the Git state with the cluster state

3. Automatically update the cluster to match Git (if automated sync is enabled)

### Deploy Infrastructure

### Accessing Argo CD

```powershell

# Validate configuration1. Get the Argo CD server address and admin password:

terraform validate```powershell

# Get Argo CD UI address

# Review planned changesterraform output argocd_server_address

terraform plan -out=tfplan

# Get admin password

# Apply configuration (~30-40 minutes)terraform output -json argocd_admin_password | jq -r '.'

terraform apply tfplan```



# Display outputs (endpoints and passwords)2. Open the Argo CD UI in your browser: `http://ARGOCD_SERVER_ADDRESS`

terraform output3. Log in with:

```   - Username: `admin`

   - Password: (from terraform output above)

### Access Services

### Updating Your Application

**Grafana (Monitoring)**

```powershellTo update your application:

kubectl port-forward -n monitoring svc/monitoring-stack-grafana 3000:80

# Open http://localhost:30001. Edit `manifests/production/deployment.yaml` (e.g., change image tag, replicas, resources)

# Username: admin2. Commit and push to the `main` branch:

# Password: terraform output -raw grafana_admin_password```bash

```git add manifests/production/

git commit -m "Update app deployment"

**Argo CD (GitOps Deployment)**git push origin main

```powershell```

kubectl port-forward -n argocd svc/argocd-server 8080:4433. Argo CD will automatically detect the change and sync to the cluster within ~3 minutes

# Open https://localhost:8080 (ignore SSL warning)4. View the sync progress in the Argo CD UI under the `uchenewwebsit-app` application

# Username: admin

# Password: terraform output -raw argocd_admin_password### Manual Sync

```

To force an immediate sync without waiting:

**Application**1. In Argo CD UI: Click the `uchenewwebsit-app` application → Click `SYNC` button

```powershell2. Or via Argo CD CLI:

kubectl port-forward svc/uchenewwebsit 8000:80```bash

# Open http://localhost:8000argocd app sync uchenewwebsit-app

``````



---### Monitoring Sync Status



## 🏗️ Infrastructure OverviewIn Argo CD UI:

- Green = Application is healthy and in sync

### What Gets Deployed- Yellow = Application is out of sync (drift detected)

- Red = Application sync failed

| Component | Purpose |

|-----------|---------|## 📊 Monitoring Stack

| **VPC & Networking** | AWS VPC with public/private subnets, NAT Gateway, Internet Gateway |

| **EKS Cluster** | Kubernetes cluster (1.31) with 3 t3.medium nodes |### Accessing Grafana

| **ECR** | Docker image registry for your application |

| **Prometheus** | Metrics collection and alerting |Grafana is exposed via a LoadBalancer service. To access the dashboard:

| **Grafana** | Metrics visualization and dashboards |

| **Argo CD** | GitOps-based continuous deployment |1. Get the Grafana URL and admin password:

```powershell

### Architecture# Get Grafana URL

- Application deployment managed by **Argo CD** (Git-driven, not Terraform)terraform output grafana_load_balancer_address

- Manifests in `manifests/production/` synced automatically to cluster

- Monitoring via Prometheus scraping Kubernetes metrics# Get admin password (sensitive)

- Dashboards in Grafana for observabilityterraform output -json grafana_admin_password | jq -r '.'

```

---

2. Open the Grafana URL in your browser (http://LOAD_BALANCER_ADDRESS)

## 📁 Project Structure3. Log in with:

   - Username: `admin`

```   - Password: (use the password from terraform output)

├── 00-provider.tf              # Provider configuration

├── 01-s3.tf → 11-eks.tf       # Infrastructure as code files### Default Monitoring

├── monitoring.tf               # Prometheus & Grafana

├── argocd.tf                   # Argo CD setupThe kube-prometheus-stack installation includes:

├── argocd-app.tf               # App synced via Git- Prometheus server for metrics collection

├── variables.tf                # Customizable variables- Grafana with pre-configured dashboards

├── terraform.tfvars            # Variable values- AlertManager for alert management

├── outputs.tf                  # Resource endpoints- Node exporter for host metrics

├── manifests/production/       # Kubernetes manifests (managed by Argo CD)- kube-state-metrics for Kubernetes object metrics

└── .github/workflows/          # GitHub Actions automation

```### Security Recommendations



---1. **Change the admin password** after first login

2. For production environments:

## 🔄 Terraform Workflow   - Add Ingress + TLS certificate instead of LoadBalancer

   - Configure LDAP/OAuth authentication

### Apply (Deploy Everything)   - Enable persistent storage for metrics retention

```powershell

terraform validate### Alternative Access Methods

terraform plan -out=tfplan

terraform apply tfplanIf you prefer not to expose Grafana via LoadBalancer:

```

```powershell

**Timing:** ~30-40 minutes (mostly EKS provisioning)# Port forward Grafana locally

kubectl -n monitoring port-forward svc/monitoring-stack-grafana 3000:80

### Destroy (Cleanup Everything)```



⚠️ **Before destroy:**Then access Grafana at: http://localhost:3000

1. Remove `prevent_destroy` from `02-vpc.tf` and `11-eks.tf` lines

2. Confirm you want to delete all resources## 🔄 Next Steps



```powershell### Persistence

terraform destroy -auto-approveTo enable persistent storage for Prometheus and Grafana:

```

1. Create an EBS storage class:

**Timing:** ~30-40 minutes (mostly EKS cluster deletion)```yaml

apiVersion: storage.k8s.io/v1

---kind: StorageClass

metadata:

## 📊 Managing Your Application via Git  name: monitoring-storage

provisioner: kubernetes.io/aws-ebs

### Update Deployment```



Edit `manifests/production/deployment.yaml`:2. Update the Helm values in `monitoring.tf`:

```yaml```hcl

spec:set = [

  replicas: 3              # Scale up/down  {

  template:    name  = "grafana.persistence.enabled"

    spec:    value = "true"

      containers:  },

      - image: your-repo:v2.0  # Change version  {

        resources:    name  = "grafana.persistence.storageClassName"

          requests:    value = "monitoring-storage"

            cpu: 250m  }

```]

```

Commit and push to `main`:

```bash### Alerting

git add manifests/production/1. Configure AlertManager in Grafana UI:

git commit -m "Update app"   - Go to Alerting -> Notification channels

git push origin main   - Add Slack/Email/PagerDuty etc.

```

2. Create alert rules:

Argo CD auto-syncs within ~3 minutes (watch in Argo CD UI).   - In Grafana: Alerting -> Rules

   - In Prometheus: Use PrometheusRule CRDs

---

### Custom Dashboards

## 🛠️ CustomizationImport recommended dashboards by ID:

- Node Exporter Full: 1860

Edit `terraform.tfvars`:- Kubernetes Cluster: 7249

```hcl- AWS EKS Monitoring: 17119

region       = "us-east-1"

cluster_name = "main_eks"### Metric Collection

docker_tag   = "latest"To monitor custom applications:

```1. Add Prometheus annotations to your Pods:

```yaml

Edit `11-eks.tf` for cluster settings:annotations:

- Node count: `scaling_config { desired_size = 3 }`  prometheus.io/scrape: "true"

- Instance type: `instance_types = ["t3.medium"]`  prometheus.io/path: "/metrics"

- Kubernetes version: `version = "1.31"`  prometheus.io/port: "8080"

```

---

2. Implement metrics endpoint in your app using client libraries:

## 📞 Troubleshooting   - [Go client](https://github.com/prometheus/client_golang)

   - [Python client](https://github.com/prometheus/client_python)

| Issue | Solution |   - [Node.js client](https://github.com/siimon/prom-client)

|-------|----------|

| **Validate fails** | Run `terraform fmt -recursive` then `terraform validate` |## 🔍 Troubleshooting

| **Plan has errors** | Verify AWS credentials: `aws sts get-caller-identity` |

| **EKS slow** | Normal! Takes 10-15 min. Total apply: 30-40 min expected |### Common Issues

| **Destroy fails** | Check for orphaned ENIs: `aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=vpc-id"` |1. Grafana shows "Bad Gateway":

   - Check if all pods are running: `kubectl -n monitoring get pods`

---   - View Grafana logs: `kubectl -n monitoring logs -l app.kubernetes.io/name=grafana`



## 📚 Key Files Reference2. Missing metrics:

   - Verify Prometheus targets: `kubectl -n monitoring port-forward svc/monitoring-stack-prometheus 9090:9090`

| File | Purpose |   - Check service discovery in Prometheus UI -> Status -> Targets

|------|---------|

| `00-provider.tf` | AWS, Kubernetes, Helm credentials |3. High resource usage:

| `11-eks.tf` | **EKS cluster** — timeouts: 30m, prevent_destroy |   - Adjust resource limits in `monitoring.tf`

| `monitoring.tf` | Prometheus/Grafana (ClusterIP service) |   - Consider enabling persistence to prevent OOM issues

| `argocd.tf` | Argo CD (ClusterIP service) |

| `manifests/production/` | **Update your app here** |### Support

For issues or feature requests:

---1. Check the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) documentation

2. Open an issue in this repository
## 🚀 GitHub Actions

Manual apply: Actions → "Terraform Apply" → "Run workflow"  
Auto plan on PR: Triggered for any `**.tf` changes

---

## ✅ Getting Outputs

```powershell
terraform output                           # All outputs
terraform output -raw grafana_admin_password
terraform output -raw argocd_admin_password
```

---

## 🔐 Security & Best Practices

- **VPC & EKS** protected with `prevent_destroy = true`
- **S3 backend** encrypted with DynamoDB locks
- **Services** use ClusterIP (no public LoadBalancers)
- **Port-forwarding** for local access (no external exposure)

---

**Last Updated:** November 12, 2025 | **Status:** ✅ Production Ready  
**See Also:** `START_HERE.md` for quick onboarding
