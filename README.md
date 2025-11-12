# EKS Application with Prometheus & Grafana Monitoring + Argo CD GitOps

This repository contains Terraform configurations for deploying a containerized application to Amazon EKS with:
- Prometheus & Grafana monitoring
- Argo CD for GitOps-based continuous deployment

## 🚀 Argo CD GitOps Deployment

### How It Works

Argo CD automatically synchronizes your Kubernetes deployments with this Git repository. When you update the manifests in `manifests/production/`, Argo CD will:
1. Detect the change
2. Compare the Git state with the cluster state
3. Automatically update the cluster to match Git (if automated sync is enabled)

### Accessing Argo CD

1. Get the Argo CD server address and admin password:
```powershell
# Get Argo CD UI address
terraform output argocd_server_address

# Get admin password
terraform output -json argocd_admin_password | jq -r '.'
```

2. Open the Argo CD UI in your browser: `http://ARGOCD_SERVER_ADDRESS`
3. Log in with:
   - Username: `admin`
   - Password: (from terraform output above)

### Updating Your Application

To update your application:

1. Edit `manifests/production/deployment.yaml` (e.g., change image tag, replicas, resources)
2. Commit and push to the `main` branch:
```bash
git add manifests/production/
git commit -m "Update app deployment"
git push origin main
```
3. Argo CD will automatically detect the change and sync to the cluster within ~3 minutes
4. View the sync progress in the Argo CD UI under the `uchenewwebsit-app` application

### Manual Sync

To force an immediate sync without waiting:
1. In Argo CD UI: Click the `uchenewwebsit-app` application → Click `SYNC` button
2. Or via Argo CD CLI:
```bash
argocd app sync uchenewwebsit-app
```

### Monitoring Sync Status

In Argo CD UI:
- Green = Application is healthy and in sync
- Yellow = Application is out of sync (drift detected)
- Red = Application sync failed

## 📊 Monitoring Stack

### Accessing Grafana

Grafana is exposed via a LoadBalancer service. To access the dashboard:

1. Get the Grafana URL and admin password:
```powershell
# Get Grafana URL
terraform output grafana_load_balancer_address

# Get admin password (sensitive)
terraform output -json grafana_admin_password | jq -r '.'
```

2. Open the Grafana URL in your browser (http://LOAD_BALANCER_ADDRESS)
3. Log in with:
   - Username: `admin`
   - Password: (use the password from terraform output)

### Default Monitoring

The kube-prometheus-stack installation includes:
- Prometheus server for metrics collection
- Grafana with pre-configured dashboards
- AlertManager for alert management
- Node exporter for host metrics
- kube-state-metrics for Kubernetes object metrics

### Security Recommendations

1. **Change the admin password** after first login
2. For production environments:
   - Add Ingress + TLS certificate instead of LoadBalancer
   - Configure LDAP/OAuth authentication
   - Enable persistent storage for metrics retention

### Alternative Access Methods

If you prefer not to expose Grafana via LoadBalancer:

```powershell
# Port forward Grafana locally
kubectl -n monitoring port-forward svc/monitoring-stack-grafana 3000:80
```

Then access Grafana at: http://localhost:3000

## 🔄 Next Steps

### Persistence
To enable persistent storage for Prometheus and Grafana:

1. Create an EBS storage class:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: monitoring-storage
provisioner: kubernetes.io/aws-ebs
```

2. Update the Helm values in `monitoring.tf`:
```hcl
set = [
  {
    name  = "grafana.persistence.enabled"
    value = "true"
  },
  {
    name  = "grafana.persistence.storageClassName"
    value = "monitoring-storage"
  }
]
```

### Alerting
1. Configure AlertManager in Grafana UI:
   - Go to Alerting -> Notification channels
   - Add Slack/Email/PagerDuty etc.

2. Create alert rules:
   - In Grafana: Alerting -> Rules
   - In Prometheus: Use PrometheusRule CRDs

### Custom Dashboards
Import recommended dashboards by ID:
- Node Exporter Full: 1860
- Kubernetes Cluster: 7249
- AWS EKS Monitoring: 17119

### Metric Collection
To monitor custom applications:
1. Add Prometheus annotations to your Pods:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "8080"
```

2. Implement metrics endpoint in your app using client libraries:
   - [Go client](https://github.com/prometheus/client_golang)
   - [Python client](https://github.com/prometheus/client_python)
   - [Node.js client](https://github.com/siimon/prom-client)

## 🔍 Troubleshooting

### Common Issues
1. Grafana shows "Bad Gateway":
   - Check if all pods are running: `kubectl -n monitoring get pods`
   - View Grafana logs: `kubectl -n monitoring logs -l app.kubernetes.io/name=grafana`

2. Missing metrics:
   - Verify Prometheus targets: `kubectl -n monitoring port-forward svc/monitoring-stack-prometheus 9090:9090`
   - Check service discovery in Prometheus UI -> Status -> Targets

3. High resource usage:
   - Adjust resource limits in `monitoring.tf`
   - Consider enabling persistence to prevent OOM issues

### Support
For issues or feature requests:
1. Check the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) documentation
2. Open an issue in this repository