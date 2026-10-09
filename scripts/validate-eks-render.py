"""Offline policy and wiring checks; requires PyYAML. No Kubernetes/AWS calls."""
import json
import sys
from pathlib import Path
import yaml

def require(condition, message):
    if not condition:
        raise SystemExit("FAIL: " + message)

source = Path(sys.argv[1])
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
objects = [o for o in yaml.safe_load_all(source.read_text(encoding="utf-8-sig")) if o]
repo = Path(__file__).resolve().parents[1]
values = yaml.safe_load((repo / "kubernetes/eks/values.yaml").read_text())
namespace = yaml.safe_load((repo / "kubernetes/eks/namespace.yaml").read_text())
require(namespace["metadata"]["name"] == "astronomy-shop", "namespace mismatch")
identities = [(o["apiVersion"], o["kind"], o["metadata"].get("namespace", "astronomy-shop"), o["metadata"]["name"]) for o in objects]
require(len(identities) == len(set(identities)), "duplicate objects")
for o in objects:
    require(o["kind"] not in {"Ingress", "PersistentVolumeClaim", "PersistentVolume"}, "external ingress or persistent storage")
    if o["kind"] == "Service":
        require(o["spec"].get("type", "ClusterIP") == "ClusterIP", "externally exposed service")
    if o["kind"] == "StatefulSet":
        require(not o["spec"].get("volumeClaimTemplates"), "StatefulSet storage claims")
workloads = [o for o in objects if o["kind"] in {"Deployment", "StatefulSet", "DaemonSet"}]
pods = [o["spec"]["template"] for o in workloads]
for o in objects:
    if o["kind"] == "Service" and o["spec"].get("selector"):
        selector = o["spec"]["selector"]
        require(any(all(p["metadata"].get("labels", {}).get(k) == v for k, v in selector.items()) for p in pods), "Service has no matching workload: " + o["metadata"]["name"])
images = []
steady_mib = 0
agent_mib = 0
for o in workloads:
    spec = o["spec"]["template"]["spec"]
    for group in ("initContainers", "containers"):
        for c in spec.get(group, []):
            image = c["image"]
            require(":" in image.rsplit("/", 1)[-1] and not image.endswith(":latest"), "unversioned image: " + image)
            images.append({"workload": o["metadata"]["name"], "container": c["name"], "type": group, "image": image})
            if group == "containers":
                r = c.get("resources", {})
                mem = r.get("requests", {}).get("memory", r.get("limits", {}).get("memory", "0Mi"))
                require(str(mem).endswith("Mi"), "extend memory parser for: " + str(mem))
                amount = float(str(mem)[:-2])
                if o["kind"] == "DaemonSet":
                    agent_mib += amount
                else:
                    steady_mib += amount * o["spec"].get("replicas", 1)
frontend = next(o for o in workloads if o["metadata"]["name"] == "frontend")
c = frontend["spec"]["template"]["spec"]["containers"][0]
v = values["components"]["frontend"]["imageOverride"]
require(c["image"] == v["repository"] + ":" + v["tag"], "frontend image mismatch")
require("@sha256:" in c["image"], "frontend must be pinned by digest")
require(len([i for i in images if ".dkr.ecr." in i["image"]]) == 1, "only frontend is published to project ECR")
env = {e["name"]: e.get("value") for e in c["env"]}
require(env["PUBLIC_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"] == "http://localhost:8080/otlp-http/v1/traces", "browser telemetry endpoint mismatch")
for name in ["AD_ADDR", "CART_ADDR", "CHECKOUT_ADDR", "CURRENCY_ADDR", "PRODUCT_CATALOG_ADDR", "RECOMMENDATION_ADDR", "SHIPPING_ADDR", "OTEL_EXPORTER_OTLP_ENDPOINT"]:
    require(name in env, "frontend dependency lost: " + name)
load = next(o for o in workloads if o["metadata"]["name"] == "load-generator")
loadenv = {e["name"]: e.get("value") for e in load["spec"]["template"]["spec"]["containers"][0]["env"]}
require(loadenv.get("LOCUST_AUTOSTART") == "false", "automatic load generation enabled")
report = {"objects": len(objects), "workloads": len(workloads), "containerReferences": len(images), "steadyEffectiveMemoryMiB": steady_mib, "collectorMemoryMiBPerNode": agent_mib, "checks": "PASS: object uniqueness, namespace, internal services, no ingress/PVC, selectors, versioned images, frontend digest/wiring, manual load generation", "limits": "Not Kubernetes API schema validation or runtime verification; effective memory uses requests or admission-defaulted limits, excluding init peaks, rolling surge and system overhead."}
(out / "validation.json").write_text(json.dumps(report, indent=2) + "\n")
(out / "image-map.json").write_text(json.dumps(images, indent=2) + "\n")
lines = ["# Rendered image mapping", "", "Generated from the locked chart plus values.yaml. Upstream tags are versioned but remain mutable; only frontend is digest-pinned. Registry availability and architecture were not queried.", "", "| Workload | Container | Type | Image |", "|---|---|---|---|"]
lines += ["| {workload} | {container} | {type} | `{image}` |".format(**i) for i in images]
(out / "image-map.md").write_text("\n".join(lines) + "\n")
print(json.dumps(report, indent=2))
