{{/*
Create a standardized ingress resource (per-item only, no global defaults)
*/}}
{{- define "ingressutil.ingress"}}
{{- $ing := .ing }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $ing.name | default $ing.subdomain }}
  labels:
    app: {{ $ing.name | default $ing.subdomain }}
  annotations:
    {{- if $ing.clusterIssuer }}
    cert-manager.io/cluster-issuer: {{ $ing.clusterIssuer }}
    {{- end }}
    {{- if $ing.annotations }}
    {{ toYaml $ing.annotations | nindent 4 }}
    {{- end }}
spec:
  tls:
    - hosts:
        - {{ $ing.subdomain }}.{{ $ing.baseUrl }}
      secretName: {{ $ing.subdomain }}-tls
  rules:
    - host: {{ $ing.subdomain }}.{{ $ing.baseUrl }}
      http:
        paths:
          - path: {{ $ing.path | default "/" }}
            pathType: {{ $ing.pathType | default "Prefix" }}
            backend:
              service:
                name: {{ $ing.serviceName | default $ing.subdomain }}
                port:
                  number: {{ $ing.port }}
{{- end -}}
