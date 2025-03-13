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
{{ range $cname, $_ := $m.spec.template.spec.containers }}
- op: set
  path: {{ $i }}.spec.template.spec.containers.{{ $cname }}.securityContext.allowPrivilegeEscalation
  value: false
- op: set
  path: {{ $i }}.spec.template.spec.containers.{{ $cname }}.securityContext.privileged
  value: false
- op: set
  path: {{ $i }}.spec.template.spec.containers.{{ $cname }}.securityContext.readOnlyRootFilesystem
  value: true
- op: set
  path: {{ $i }}.spec.template.spec.containers.{{ $cname }}.securityContext.capabilities.drop
  value: ["ALL"]
{{ end }}
{{ end }}
{{ end }}
