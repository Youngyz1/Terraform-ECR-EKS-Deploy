# GitHub Actions Setup for Terraform

This repository uses GitHub Actions to manage Terraform deployments to AWS.

## Workflows

### 1. Terraform Apply (Manual Trigger)
**File:** `.github/workflows/terraform-apply.yml`

Manually trigger Terraform apply to deploy/update AWS infrastructure.

**How to use:**
1. Go to GitHub repo → Actions → "Terraform Apply (Manual Trigger)"
2. Click "Run workflow"
3. Select environment (production/staging)
4. Click "Run workflow"
5. Monitor the logs for success/failure

**What it does:**
- Runs `terraform init`
- Runs `terraform plan`
- Runs `terraform apply -auto-approve`
- Outputs Grafana and Argo CD URLs
- Uploads the terraform plan as artifact

### 2. Terraform Plan (CI on PR)
**File:** `.github/workflows/terraform-plan.yml`

Automatically runs when you create a PR with Terraform file changes.

**What it does:**
- Runs `terraform fmt -check` (validates formatting)
- Runs `terraform validate` (validates HCL syntax)
- Runs `terraform plan` (shows what changes will happen)
- Comments on the PR with the plan output

## Setup Instructions

### 1. Create IAM Role for GitHub Actions

In AWS, create an IAM role that GitHub Actions can assume:

```bash
# Create trust policy JSON
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:Youngyz1/Terraform-ECR-EKS-Deploy:*"
        }
      }
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name github-actions-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policies (give it permissions to create/manage AWS resources)
aws iam attach-role-policy \
  --role-name github-actions-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Note: AdministratorAccess is broad; for production, create a custom policy with minimal permissions
```

### 2. Add GitHub Secrets

In GitHub repo settings → Secrets and variables → Actions:

Add these secrets:
- `AWS_ACCOUNT_ID`: Your AWS account ID (e.g., 123456789012)

The role ARN in the workflows will be: `arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/github-actions-role`

### 3. Enable OpenID Connect (OIDC) in AWS

GitHub Actions uses OIDC to assume the IAM role (no long-lived AWS credentials stored):

```bash
# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## Workflow Trigger Methods

### Manual Trigger (Terraform Apply)
```
GitHub UI: Actions → Terraform Apply (Manual Trigger) → Run workflow
```

### Automatic Trigger (Terraform Plan on PR)
```
Push a branch with .tf changes → Create Pull Request → Plan runs automatically
```

## Security Best Practices

1. **Use OIDC** (already configured) — No AWS credentials stored in GitHub
2. **Limit Role Permissions** — Replace `AdministratorAccess` with minimal required policy
3. **Use `auto-approve` with caution** — Always review `terraform plan` output first
4. **Protect main branch** — Require PR reviews before merge
5. **Use separate AWS accounts** for staging/production

## Troubleshooting

### Workflow fails with "role not found"
- Ensure IAM role exists: `aws iam get-role --role-name github-actions-role`
- Ensure OIDC provider exists: `aws iam list-open-id-connect-providers`

### Terraform state lock timeout
- Check S3 state lock: `aws s3 ls s3://youngyz-terraform-state/`
- Manual unlock if needed: `terraform force-unlock <LOCK_ID>`

### AWS credentials not available
- Verify OIDC trust relationship matches your repo
- Check that secrets are set in GitHub Actions

## Next Steps

1. Push these workflow files to your repo
2. Create the IAM role and OIDC provider using commands above
3. Add `AWS_ACCOUNT_ID` secret to GitHub
4. Test by running the "Terraform Apply" workflow manually
5. Create a PR to test the "Terraform Plan" workflow

## Manual Local Deployment (Alternative)

If GitHub Actions fails or you prefer local control:

```powershell
cd path/to/repo
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
