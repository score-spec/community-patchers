{{/* Adapt this user value as per your own context */}}
{{ $user := "guest" }}

{{ $namespace := .Namespace }}
{{ $componentAndResourcePrefix := ne $namespace "" | ternary (print $namespace "-") "" }}

{{/* remove the default generated manifests */}}
{{ range $i, $m := (reverse .Manifests) }}
{{ $i := sub (len $.Manifests) (add $i 1) }}
- op: delete
  path: {{ $i }}
{{ end }}

{{/* generate System if --generate-namespace is supplied */}}
{{ range $i, $m := .Manifests }}
{{ if eq $m.kind "Namespace" }}
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
{{ end }}

{{/* generate a Component per Workload */}}
{{ range $name, $spec := .Workloads }}
- op: set
  path: -1
  value:
    apiVersion: backstage.io/v1alpha1
    kind: Component
    metadata:
      name: {{ $componentAndResourcePrefix }}{{ $name }}
      title: {{ $name }}
      description: {{ $name }}
      annotations:
        github.com/project-slug: $GITHUB_REPO
        {{/* add more annotations on this Workload based on your own needs */}}
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
      {{ range $rname, $rspec := $spec.resources }}
      {{ if eq $rspec.type "service" }}
      - 'resource:{{ $componentAndResourcePrefix }}{{ $rname }}'
      {{ else }}
      {{ if ne $rspec.type "route" }}
      - 'resource:{{ $componentAndResourcePrefix }}{{ $name }}-{{ $rname }}'
      {{ end }}
      {{ end }}
      {{ end }}
{{/* generate a Resource per Workload's resource */}}
{{ range $rname, $rspec := $spec.resources }}
{{ if ne $rspec.type "route" }}
- op: set
  path: -1
  value:
    apiVersion: backstage.io/v1alpha1
    kind: Resource
    metadata:
      name: {{ $componentAndResourcePrefix }}{{ $name }}-{{ $rname }}
      title: {{ $rname }}
      description: '{{ $rname }} (type: {{ $rspec.type }}) of {{ $name }}'
    spec:
      type: {{ $rspec.type }}
      owner: user:{{ $user }}
      {{ if ne $namespace "" }}
      system: {{ $namespace }}
      {{ end }}
{{ end }}
{{ end }}
{{ end }}