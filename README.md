# Secure AWS Infrastructure with Terraform + CI Security Pipeline

A security-focused Infrastructure as Code (IaC) project demonstrating how AWS infrastructure can be designed with Terraform and automatically validated through a GitHub Actions CI pipeline.

The project emphasizes secure-by-default architecture, automated security scanning, least privilege, logging, encryption, and cost-conscious cloud design.

## Architecture

The Terraform configuration defines:

- AWS VPC with public and private subnets
- Internet Gateway and controlled routing
- Restricted default security group
- Security group with no inbound access and HTTPS-only outbound traffic
- VPC Flow Logs
- CloudWatch log storage with 365-day retention
- IAM roles and least-privilege policies
- Secure S3 data bucket
- Dedicated S3 access-log bucket
- S3 encryption, versioning, lifecycle controls, and public-access blocking

No EC2 instances, NAT Gateways, load balancers, RDS databases, or other unnecessary compute resources are required.

## Security Controls

Key controls implemented include:

- S3 Block Public Access
- S3 encryption at rest
- S3 versioning
- S3 lifecycle management
- S3 access logging
- IAM least privilege
- Restricted security groups
- Restricted default VPC security group
- VPC Flow Logs
- CloudWatch log retention
- Automated Checkov Infrastructure-as-Code security scanning

## Terraform Structure

```text
.
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
├── iam.tf
├── network.tf
├── provider.tf
├── security.tf
├── storage.tf
├── versions.tf
└── README.md
```

## CI Security Pipeline

Every push or pull request to `main` automatically triggers GitHub Actions.

```text
Developer
    ↓
Git Commit / Push
    ↓
GitHub
    ↓
GitHub Actions
    ↓
Terraform Init
    ↓
Terraform Format Check
    ↓
Terraform Validate
    ↓
Checkov IaC Security Scan
    ↓
Security Findings / CI Result
```

The pipeline performs repository checkout, Terraform installation, `terraform init -backend=false`, `terraform fmt -check -recursive`, `terraform validate`, and Checkov Terraform security scanning.

This provides automated validation and security feedback whenever infrastructure code changes.

## Security Scan Results

Current Checkov scan:

- **61 passed checks**
- **8 identified findings**
- **0 skipped checks**

The remaining findings were reviewed rather than blindly remediated simply to achieve a zero-finding scan.

Examples include cross-region S3 replication, S3 event notifications, customer-managed KMS encryption for selected logging resources, and security-group attachment to compute resources.

Some controls would require additional AWS services, resources, or cost that are outside the scope of this deliberately cost-conscious lab.

This demonstrates an important security-engineering principle: scanner findings require risk analysis and architectural context rather than automatic remediation.

## Deployment Safety

The CI pipeline intentionally does **not** execute `terraform apply`.

Its purpose is to validate and security-scan infrastructure code without automatically provisioning AWS resources.

A production deployment pipeline could extend this design with Terraform plan review, GitHub OIDC authentication to AWS, protected environments, manual approval gates, and controlled `terraform apply`.

This separation reduces the risk of unintended infrastructure creation and cloud charges during the lab.

## Cost Considerations

The project was designed to minimize AWS cost. Expensive or unnecessary components such as NAT Gateways, EC2 instances, Elastic IPs, load balancers, and RDS were deliberately excluded.

Some defined services, including CloudWatch logging and VPC Flow Logs, may incur charges if deployed and used. The CI pipeline performs static validation and security scanning without deploying the infrastructure.

## What This Project Demonstrates

- Terraform Infrastructure as Code
- AWS networking and security architecture
- IAM least privilege
- Secure S3 configuration
- AWS logging and monitoring concepts
- Git and GitHub workflow
- GitHub Actions CI
- Automated IaC security scanning with Checkov
- Security finding analysis
- Cloud cost awareness
- Secure infrastructure lifecycle practices

## Lessons Learned

This project demonstrates that cloud security is not simply about making every automated scanner check green. Security controls must be evaluated against architecture, operational requirements, risk, and cost.

Automating Terraform validation and security scanning through CI provides early feedback before infrastructure reaches a deployment stage.
