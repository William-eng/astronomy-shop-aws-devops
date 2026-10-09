[CmdletBinding()]
param([string]$OutputDirectory = (Join-Path $PSScriptRoot '../work/eks-validation'))
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$config = Join-Path $repo 'kubernetes/eks'
$lock = Get-Content (Join-Path $config 'chart-lock.json') -Raw | ConvertFrom-Json
foreach ($tool in @('helm', 'python')) { Get-Command $tool -ErrorAction Stop | Out-Null }
& python -c "import yaml"
if ($LASTEXITCODE -ne 0) { throw 'Python requires PyYAML; install it in your chosen Python environment.' }
New-Item -ItemType Directory -Force $OutputDirectory | Out-Null
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
$archive = Join-Path $OutputDirectory ('opentelemetry-demo-' + $lock.chartVersion + '.tgz')
if (-not (Test-Path $archive)) {
    Invoke-WebRequest -Uri $lock.url -OutFile $archive
}
if ((Get-FileHash $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $lock.sha256) {
    throw 'Chart checksum mismatch. Do not use this archive.'
}
& helm lint $archive --strict -f (Join-Path $config 'values.yaml')
if ($LASTEXITCODE -ne 0) { throw 'Helm lint failed.' }
$rendered = & helm template $lock.release $archive --namespace $lock.namespace --kube-version $lock.kubernetesVersion -f (Join-Path $config 'values.yaml')
if ($LASTEXITCODE -ne 0) { throw 'Helm rendering failed.' }
$manifest = Join-Path $OutputDirectory 'rendered.yaml'
$rendered | Set-Content -Encoding utf8 $manifest
& python (Join-Path $PSScriptRoot 'validate-eks-render.py') $manifest $OutputDirectory
if ($LASTEXITCODE -ne 0) { throw 'Rendered manifest checks failed.' }
Write-Host "Static validation completed: $OutputDirectory"
Write-Host 'No cluster connection, AWS API call, installation or deployment was performed.'
