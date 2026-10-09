# Phase 6 - EKS deployment preparation and observability baseline

Status: prepared and statically checked on 9 October 2026; **not deployed**.
The $10 monthly budget blocks running EKS. This phase follows the existing Phase 5.5 CI/CD notes. The original roadmap calls Phase 6 observability; this guide prepares both deployment and its upstream observability baseline, without claiming either is operational.

## Inspected evidence

- Repository: William-eng/astronomy-shop-aws-devops, local HEAD `0d99d9c3138ed121a02883b491358c7106650186` at inspection.
- `app` gitlink and local HEAD: `e5552ee25bcede2900d89188f076c464cd73c074`, also the gitlink in frontend build commit `a7da32eafe17bc72a9cfca69f1230dcfc23a73e0`.
- App `.env` identifies demo 3.1.0. The app checkout contains Compose configuration and points to Kubernetes documentation; it does not contain the demo Helm chart. Kubernetes templates live in the separate upstream Helm repository.
- Existing GitHub workflow builds only frontend and pushes a parent-repository SHA tag to ECR. The recorded successful digest comes from the CI documentation and supplied logs; ECR availability was not independently queried.
- Pre-existing untracked files inside `app` (`frontend-build.log`, `src/frontend/Dockerfile.dev`) were preserved. No app source, Terraform, IAM policy or image-publishing workflow was changed.

## Deployment decision

Use the official `opentelemetry-demo` chart **0.42.3**, appVersion **3.1.0**, with project overrides in `kubernetes/eks/values.yaml`. `chart-lock.json` records the exact release URL, SHA256, source commit and target Kubernetes version 1.34.0. Downloaded archive SHA256 matched the Helm repository index. Dependencies are bundled in the release archive; do not run dependency update or render an unpinned latest chart.

The chart supplies service DNS, environment variables, probes where upstream provides them, configuration, service accounts, RBAC, application workloads and telemetry backends. Keep that service graph instead of recreating frontend alone. Same appVersion is a useful baseline, not proof that the source commit equals a release tag: runtime compatibility remains a gate. Chart dependency image versions also differ from the app's Compose defaults.

Deploy one Helm release `astronomy-shop` into namespace `astronomy-shop`. The chart uses fixed service names, so use only one instance per namespace. Namespace creation is a separate manifest. Application workloads target Linux amd64, matching the existing standard GitHub runner build assumption; verify the actual ECR image architecture before deployment. Choose matching amd64 managed nodes for all workloads, including dependency charts.

The profile retains Collector, Jaeger, Prometheus, Grafana and OpenSearch. It keeps the load-generator service but disables automatic traffic and browser traffic; start a short one-user test manually later. AI demo components retain upstream recorded-fixture mode and receive no paid API credentials. Profiling remains disabled. Application CPU requests start at 50m and memory requests match upstream memory limits; these are conservative preparation settings, not measured production sizing. OpenSearch memory request is raised to match its 1100Mi limit. Runtime tuning remains necessary.

## Images and frontend configuration

Only frontend maps to project ECR:

`975050251876.dkr.ecr.us-east-1.amazonaws.com/astronomy-shop/frontend:a7da32eafe17bc72a9cfca69f1230dcfc23a73e0@sha256:abfa1fee95bcee4da40f78865026312714f533c009ed9fab479d1a575e6d3c89`

The chart's image template always joins repository and tag with a colon. Supplying `tag@sha256:digest` gives a valid digest-pinned image reference; the digest determines the pulled content. Do not replace the chart's global repository with the frontend ECR repository: backend images have not been built there. A commit-shaped tag alone is not an immutability guarantee.

Other application images retain `ghcr.io/open-telemetry/demo:3.1.0-<component>`. Infrastructure images retain their chart versions. BusyBox init images are explicitly versioned at 1.37.0. See [the complete rendered image map](phase-06-image-map.md), including init containers and Grafana sidecars. These upstream tags remain mutable; verify availability, architecture and preferably resolve digests before a live rollout.

Frontend service remains port 8080. Its upstream backend addresses and Collector endpoint are preserved. `ENV_PLATFORM=aws`; browser traces go to `http://localhost:8080/otlp-http/v1/traces` through frontend-proxy. Forward **frontend-proxy**, not frontend, to retain images, browser telemetry and backend UI routing. The frontend readiness probe checks `/`; it does not prove checkout or downstream service health.

ECR pulling on managed nodes uses the node IAM role, which already attaches `AmazonEC2ContainerRegistryPullOnly` in Terraform. GitHub's OIDC push role is a separate identity and receives no cluster access here. No static ECR imagePullSecret is added. Verify node-role permissions, repository policy and network access together before deployment.

## Budget and platform blockers

1. **Budget:** AWS standard-support EKS control plane is $0.10/hour: about $73 for 730 hours, before compute, EBS, networking, logs and tax. Even 100 cluster-hours alone consumes $10. Neither always-on EKS nor an assumed short lab is authorized under the current total monthly cap. Keep `enable_eks=false` and `enable_nat_gateway=false`. Existing ECR/S3 usage and other account costs were not audited; this work does not certify the whole account is below $10. Budget alerts are not hard spending caps.
2. **Private subnet egress:** managed nodes use private subnets; NAT is off and no endpoints are defined. The mixed ECR/GHCR/Docker Hub/Quay image set needs outbound connectivity. A future private-only design would require mirrored images, ECR API/DKR plus S3 connectivity, required AWS API endpoints (including EKS Auth for Pod Identity), and handling Grafana's plugin download. ECR endpoints alone do not provide access to public registries. NAT or interface endpoints introduce costs and need a separately funded design.
3. **Capacity:** this render requires roughly **9672MiB plus 400MiB per node** of effective steady memory requests, including Kubernetes' defaulting of omitted requests to limits. Excludes init peaks, rolling-update surge, OS, kube-system, pod networking and safety margin. A single t3.medium (4GiB physical RAM) cannot fit it; even the configured maximum of two cannot. Node-group max=2 does not install an autoscaler. Recalculate allocatable CPU/RAM, pod limits, storage and rollout headroom before selecting larger capacity. Disabling random backends to fit would break the graph.
4. **API access:** root Terraform enables public endpoint access but supplies an empty approved-CIDR list. The module precondition intentionally blocks enabling EKS in this state. Supply an approved operator CIDR or a working private administration path; do not open access to the internet.
5. **Identity/bootstrap:** confirm `astronomy-dev` (Terraform) versus `default` (earlier CLI work) resolves to the intended account, and verify the hard-coded admin principal. Validate VPC CNI/Pod Identity startup order and compatible add-on versions; successful Terraform validation does not establish that nodes can become Ready. Verify CoreDNS and kube-proxy readiness as well. Recheck EKS version support at rollout time.
6. **Runtime/security:** the upstream demo includes demo passwords, anonymous Grafana access, disabled OpenSearch security and broad Collector RBAC/host access. It is an isolated disposable lab profile, not a production hardening baseline. No Ingress, LoadBalancer, public DNS or persistent volumes are rendered. Keep access bound to localhost. Data and telemetry are ephemeral and lost on restart/removal; disk usage still consumes worker storage.

## Repeatable offline validation (PowerShell)

Run from the repository root using existing Helm, Python and PyYAML:

```powershell
.\scripts\Validate-EksDeployment.ps1
terraform fmt -check -recursive terraform
terraform -chdir=terraform/environments/dev validate -no-color
```

The script only downloads the locked chart if absent, verifies SHA256, runs strict Helm lint, renders locally and checks the YAML. It never calls kubectl, AWS APIs, Terraform apply or Helm install. It writes `work/eks-validation/` (ignored by Git). To repeat without network, place the exact verified chart archive there first. The Terraform validation command requires already-installed modules/providers; those were available during this review. No init, plan, backend access or apply was run.

Results:

| Check | Result |
|---|---|
| Chart archive checksum | Matched locked release/index SHA256 |
| Strict Helm lint / chart values schema | Passed |
| Helm template for Kubernetes 1.34.0 | Passed: 93 objects, 30 workloads, 42 container references |
| Namespace, duplicate identities, service selectors | Passed |
| No Ingress, external Services, PV/PVC or StatefulSet volume claims | Passed |
| Versioned images, frontend digest and dependency variables | Passed |
| Automatic load generation disabled | Passed |
| Terraform formatting and validate | Passed using existing installed provider |
| Kubernetes API schema/admission and server dry-run | Not performed |
| Image pulls, node startup, DNS, probes, checkout, telemetry | Not performed |
| Infracost organization policies/cost scan | Unavailable: installed 2.1.0 below skill's 2.2.0 floor; auth refresh failed. No Terraform was generated or modified. |

Rendered output and reports are review artifacts. Do not apply `rendered.yaml` and also install the chart; use Helm as the future release owner. A render is not evidence of EKS readiness or application health.

## Future rollout gates and runbook (not authorized or executed)

Remain in static preparation while the $10 cap applies. A live EKS session requires an explicitly funded time window, known current spend, a full cost estimate, teardown ownership and resolution of all platform blockers above. No provisioning command is supplied here.

Once an independently approved cluster exists:

1. Verify AWS account and operator identity, API access and current kubectl context. Confirm intended cluster `astronomy-shop-dev-eks`, correct region, Ready nodes, allocatable capacity, CoreDNS/CNI/Pod Identity health, image reachability and the frontend digest. Review ClusterRole permissions in the render with the cluster administrator.
2. Run server-side dry-run against the manifests, review admission errors and obtain any missing schema/add-on compatibility evidence. Keep this separate from current offline checks.
3. Apply only the namespace manifest; install the checksum-verified chart archive using release/namespace and values from the lock. Suggested Helm arguments after approval: `upgrade --install astronomy-shop <verified-archive> --namespace astronomy-shop -f kubernetes/eks/values.yaml --wait --timeout 15m`. Review failure state and clean it up rather than leaving billable infrastructure unattended.
4. Check rollout status for all Deployments, the OpenSearch StatefulSet and Collector DaemonSet, plus pod events. Diagnose Pending versus ImagePullBackOff versus readiness failures separately.
5. Forward the proxy on localhost in a separate PowerShell terminal:

```powershell
kubectl --namespace astronomy-shop port-forward service/frontend-proxy 8080:8080 --address 127.0.0.1
```

6. Open `http://localhost:8080`, browse a product, add to cart and complete a demo checkout. Check images and browser network errors. Inspect `/jaeger/ui/` for a frontend-to-backend trace and `/grafana/` for populated metrics/log dashboards. Verify Collector exporters are healthy and OpenSearch receives logs; do not count an empty UI as success. Optionally start a one-user load test via `/loadgen/`, then stop it.
7. Record pod image IDs, build SHA, chart checksum, context, UTC test times and evidence. For later image changes, build/push through the existing workflow, record the new digest, update only frontend image mapping, rerender and review. Cluster deployment automation and deploy-role RBAC are a separate phase.
8. For a failed upgrade, review `helm history` and roll back to a known revision; on a first installation there is no prior revision, so uninstall the lab release. Helm rollback does not restore ephemeral data. At session end stop forwarding/load, uninstall the release, inspect remaining namespaced/cluster-scoped objects, and have the infrastructure owner remove the approved lab infrastructure. Helm uninstall alone does not stop EKS control-plane or node charges. Verify removal of nodes, cluster, NAT/EIPs, endpoints, disks and unwanted logs against the approved scope; retain the state backend and ECR artifacts unless separately authorized.

## Sources checked 9 October 2026

- [Upstream Kubernetes deployment](https://opentelemetry.io/docs/demo/kubernetes-deployment/)
- [Pinned Helm chart source](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/opentelemetry-demo-0.42.3/charts/opentelemetry-demo)
- [Helm chart release archive](https://github.com/open-telemetry/opentelemetry-helm-charts/releases/download/opentelemetry-demo-0.42.3/opentelemetry-demo-0.42.3.tgz)
- [EKS pricing](https://aws.amazon.com/eks/pricing/)
- [EKS private cluster connectivity](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html)
- [ECR image pulls on EKS](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html)
- [T3 instance memory specifications](https://aws.amazon.com/ec2/instance-types/t3/)
