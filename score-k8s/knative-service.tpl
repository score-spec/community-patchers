{{/* range in reverse order */}}
{{ range $i, $m := (reverse .Manifests) }}
{{/* fix the index to be reversed as well */}}
{{ $i := sub (len $.Manifests) (add $i 1) }}
- op: delete
  path: {{ $i }}
{{ end }}

{{/* generate a Service per Workload */}}
{{ range $name, $spec := .Workloads }}
- op: set
  path: -1
  value:
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: {{ $name }}
    spec:
      template:
        spec:
          containers:
            {{ range $cname, $cspec := $spec.containers }}
            - name: {{ $cname }}
              image: {{ $cspec.image }}
            {{ end }}
{{ end }}
