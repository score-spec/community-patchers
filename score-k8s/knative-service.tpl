{{ range $i, $m := .Manifests }}
{{ if eq $m.kind "Service" }}
- op: delete
  path: {{ $i }}
{{ end }}
{{ if eq $m.kind "Deployment" }}
- op: set
  path: {{ $i }}.kind
  value: Service
- op: set
  path: {{ $i }}.apiVersion
  value: serving.knative.dev/v1
- op: delete
  path: {{ $i }}.spec.selector
- op: delete
  path: {{ $i }}.spec.strategy
- op: delete
  path: {{ $i }}.status
{{ end }}
{{ end }}