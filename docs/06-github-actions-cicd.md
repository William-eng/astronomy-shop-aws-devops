# Phase 5.5 � GitHub Actions CI/CD

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

## CI/CD Validation — Successful

**Commit:** `a7da32e`

**Result:** GitHub Actions successfully built and published the Astronomy Shop frontend Docker image to Amazon ECR.

**Image repository:** `975050251876.dkr.ecr.us-east-1.amazonaws.com/astronomy-shop/frontend`

**Image digest:** `sha256:abfa1fee95bcee4da40f78865026312714f533c009ed9fab479d1a575e6d3c89`

### Issue encountered and resolution

The initial pipeline failed because the GitHub OIDC subject did not match the AWS IAM trust policy.

We inspected the OIDC token claims and updated the IAM trust policy to match the repository's actual identity, retaining the restriction to the `main` branch.

### Outcome

- GitHub Actions can authenticate to AWS without stored AWS access keys.
- The frontend image builds successfully in GitHub Actions.
- The image is published to Amazon ECR with an immutable commit-based tag.
- The pipeline is ready for Kubernetes deployment integration.

### Next phase

Prepare Kubernetes manifests for Astronomy Shop and validate the EKS infrastructure configuration before provisioning.