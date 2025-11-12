########################################################
# Argo CD Application for GitOps-based app deployment
########################################################

# Create Argo CD Application manifest file
resource "local_file" "argocd_app_manifest" {
  filename = "${path.module}/.argocd-app.yaml"
  content  = <<-EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: uchenewwebsit-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Youngyz1/Terraform-ECR-EKS-Deploy.git
    targetRevision: main
    path: manifests/production
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOT
}

# Apply the Argo CD Application manifest
resource "null_resource" "argocd_app" {
  provisioner "local-exec" {
    # Wait for Argo CD to be ready, then apply the manifest
    command = "powershell -Command \"Start-Sleep -Seconds 10; kubectl apply -f ${local_file.argocd_app_manifest.filename} --validate=false\""
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_namespace.argocd,
    local_file.argocd_app_manifest
  ]

  triggers = {
    argocd_release = helm_release.argocd.id
  }
}
