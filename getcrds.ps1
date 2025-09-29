# Create a folder for the CRDs
$crdPath = "$HOME\.intellij-k8s-crds"
New-Item -ItemType Directory -Force -Path $crdPath | Out-Null

# Get all CRD names
$crds = kubectl get crd -o name

# Export each CRD into its own YAML file
foreach ($crd in $crds) {
    $fileName = $crd.Replace("/", "_") + ".yaml"
    kubectl get $crd -o yaml | Out-File -FilePath (Join-Path $crdPath $fileName) -Encoding utf8
}

Write-Host "CRDs saved to $crdPath"