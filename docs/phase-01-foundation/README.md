# Phase 1: AWS Foundation and Project Setup

## Objective

Prepare a secure, version-controlled development environment for deploying the OpenTelemetry Astronomy Shop on AWS.

## Development Environment

* Operating system: Windows 11
* Terminal: PowerShell
* AWS Region: us-east-1
* AWS CLI: 1.41.7
* Terraform: 1.14.3
* Git: 2.50.1
* kubectl: 1.33.0
* Docker CLI: 29.7.2

## Implementation

### 1\. AWS Account Verification

Verified AWS CLI authentication using AWS STS.

### 2\. Cost Management

Confirmed an existing $10 monthly AWS budget.

Configured thresholds identified:

* 85% actual spending
* 100% actual spending
* 100% forecasted spending

Confirmed an email subscriber for the 85% alert.

### 3\. Identity Security

Registered and verified an MFA device for the IAM user.

Note: MFA registration does not automatically protect long-lived CLI credentials.

### 4\. Version Control

Created the local Git repository and connected it to GitHub.

Repository:
https://github.com/William-eng/astronomy-shop-aws-devops

Created the initial project structure and pushed the first commit to main.

## Verification Evidence

Screenshots are stored in the screenshots directory.

## Pending Security Review

Review AWS CLI credential configuration and permissions before provisioning infrastructure.

## Outcome

The AWS account, local development tools, and GitHub repository have been prepared for the next implementation phase.



\## AWS Authentication Security



AWS CLI v2 was installed and verified.



An MFA-backed temporary credential profile named

`astronomy-dev` was created using AWS STS GetSessionToken.



The temporary credentials have a one-hour lifetime.



AWS authentication was verified using:



aws sts get-caller-identity --profile astronomy-dev



Security considerations:

\- Long-lived credentials are not stored in GitHub.

\- Temporary credentials are used for local development.

\- MFA is enabled for the IAM user.

\- AdministratorAccess remains attached and requires

&#x20; future least-privilege improvement.

\- GitHub Actions will use AWS OIDC federation.

