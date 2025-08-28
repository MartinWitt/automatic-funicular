{{/*
Create a standardized ingress resource
*/}}
{{- define "ingress-util.ingress"}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Values.ingress.name | default .Values.ingress.subdomain }}
  labels:
    app: {{ .Values.ingress.name | default .Values.ingress.subdomain }}
  annotations:
    cert-manager.io/cluster-issuer: {{ .Values.ingress.clusterIssuer }}
    {{ if .Values.ingress.annotations }}
    {{ toYaml .Values.ingress.annotations | nindent 4 }}
    {{ end }}
spec:
  tls:
    - hosts:
        - {{ .Values.ingress.subdomain }}.{{ .Values.ingress.baseUrl }}
      secretName: {{ .Values.ingress.subdomain }}-tls
  rules:
    - host: {{ .Values.ingress.subdomain }}.{{ .Values.ingress.baseUrl }}
      http:
        paths:
          - path: {{ .Values.ingress.path | default "/" }}
            pathType: {{ .Values.ingress.pathType | default "Prefix" }}
            backend:
              service:
                name: {{ .Values.ingress.serviceName | default .Values.ingress.subdomain }}
                port:
                  number: {{ .Values.ingress.port }}
{{- end -}}
