# ingress-util — Guide

Overview
- This guide documents the ingress-util Helm chart (library) templates that render one or multiple Kubernetes Ingress resources from explicit per-item entries.
- The chart no longer uses global/default ingress fields; every ingress must be defined in ingress.items.

Files
- charts/ingress-util/values.schema.json — JSON Schema used for editor autocompletion.
- charts/ingress-util/values.yaml — example placeholder; real values live in your deployment values files.
- charts/ingress-util/templates/_helpers.tpl — helper that renders a single Ingress from a per-item object.
- charts/ingress-util/templates/ingress.yaml — iterates ingress.items and renders each ingress.

Required fields per item
- subdomain (string) — left part of the host (required)
- baseUrl (string) — domain (required)
- serviceName (string) — backend service name (required)
- port (integer) — backend port (required)

Optional fields per item
- name, clusterIssuer, path, pathType, annotations

Example values (docs/ingress-util/example-values.yaml)
Use this file as a starting point for providing values to helm:

- subdomain and baseUrl are combined into host: "{{subdomain}}.{{baseUrl}}"

Commands
- Validate/render templates locally (install helm):
  helm template my-release ./charts/ingress-util -f docs/ingress-util/example-values.yaml --show-only charts/ingress-util/templates/ingress.yaml

Editor autocompletion
- The repository includes charts/ingress-util/values.schema.json and a .vscode workspace setting to associate the schema with charts/ingress-util/values.yaml. In VS Code (Red Hat YAML extension) you will get key/type completions when editing values.

Notes
- Ensure each item provides its own required fields; the templates will not fall back to global values.
- If you want the chart to be installable (not library), change Chart.yaml type to "application" and bump the version.

If you want, I can also add inline examples in the schema, expand optional fields, or add a short tutorial on using cert-manager with the generated TLS secrets.
