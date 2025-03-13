{{ range $i, $m := .Manifests }}
{{ if eq $m.kind "Deployment" }}
- op: set
  path: {{ $i }}.spec.template.spec.automountServiceAccountToken
  value: false
- op: set
  path: {{ $i }}.spec.template.spec.securityContext.fsGroup
  value: "65532"
- op: set
  path: {{ $i }}.spec.template.spec.securityContext.runAsGroup
  value: "65532"
- op: set
  path: {{ $i }}.spec.template.spec.securityContext.runAsNonRoot
  value: true
- op: set
  path: {{ $i }}.spec.template.spec.securityContext.runAsUser
  value: "65532"
- op: set
  path: {{ $i }}.spec.template.spec.securityContext.seccompProfile.type
  value: "RuntimeDefault"
{{ end }}
{{ end }}
