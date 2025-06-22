{{/* Adapt this user value as per your own context */}}
{{ $user := "guest" }}

{{ $namespace := .Namespace }}

{{/* remove the default manifests */}}
{{ range $i, $m := (reverse .Manifests) }}
{{ $i := sub (len $.Manifests) (add $i 1) }}
- op: delete
  path: {{ $i }}
{{ end }}

{{/* generate System if --namespace is supplied */}}
{{ if ne $namespace "" }}
- op: set
  path: -1
  value:
    apiVersion: backstage.io/v1alpha1
    kind: System
    metadata:
      name: {{ $namespace }}
      description: {{ $namespace }}
      annotations:
        github.com/project-slug: $GITHUB_REPO
      links:
        - url: https://github.com/$GITHUB_REPO
          title: Repository
          icon: github
    spec:
      owner: user:{{ $user }}
{{ end }}
{{/* generate a Component per Workload */}}
{{ range $name, $spec := .Workloads }}
- op: set
  path: -1
  value:
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: {{ $name }}
      description: {{ $name }}
      annotations:
        github.com/project-slug: $GITHUB_REPO
      links:
        - url: https://github.com/$GITHUB_REPO
          title: Repository
          icon: github
      {{ $tags := dig "metadata" "annotations" "tags" "" $spec }}
      {{ if ne $tags "" }}
      tags:
      {{ range $tag := $tags | splitList "," }}
      - {{ $tag }}
      {{ end }}
      {{ end }}
    spec:
      type: service
      lifecycle: experimental
      owner: user:{{ $user }}
      {{ if ne $namespace "" }}
      system: {{ $namespace }}
      {{ end }}
      dependsOn:
      {{ range $cname, $cspec := $spec.resources }}
      {{ if eq $cspec.type "service" }}
      - 'component:{{ $cname }}'
      {{ else }}
      {{ if ne $cspec.type "route" }}
      - 'resource:{{ $cname }}'
      {{ end }}
      {{ end }}
      {{ end }}
{{/* generate a Resource per Workload's resource */}}
{{ range $cname, $cspec := $spec.resources }}
{{ if ne $cspec.type "route" }}
- op: set
  path: -1
  value:
    apiVersion: backstage.io/v1alpha1
    kind: Resource
    metadata:
      name: {{ $name }}-{{ $cname }}
      description: '{{ $cname }} (type: {{ $cspec.type }}) of {{ $name }}'
    spec:
      type: {{ $cspec.type }}
      owner: user:{{ $user }}
      {{ if ne $namespace "" }}
      system: {{ $namespace }}
      {{ end }}
{{ end }}
{{ end }}
{{ end }}