# Phase 5.5 — GitHub Actions CI/CD

## Objective
Automate frontend Docker image builds and publishing to Amazon ECR.

## Architecture
GitHub Repository -> GitHub Actions -> AWS OIDC -> Amazon ECR

## Security
- AWS authentication uses OIDC.
- No long-lived AWS access keys are stored in GitHub.
- IAM trust is restricted to the repository's main branch.
- ECR push permissions are scoped to the frontend repository.

## Pipeline
1. Checkout source code and submodule.
2. Assume the AWS IAM role.
3. Authenticate to Amazon ECR.
4. Build the frontend image.
5. Push the image tagged with the Git commit SHA.

## Validation
Pending first GitHub Actions execution.

## Known Issues
Local Docker builds previously failed during npm installation.
A subsequent build attempt encountered a Docker Hub timeout.

## Next Steps
- Validate GitHub Actions execution.
- Confirm image availability in ECR.
- Prepare EKS deployment manifests.
