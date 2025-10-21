{{/* range in reverse order */}}
{{ range $i, $m := (reverse .Manifests) }}
{{/* keep Namespace when --create-namespace is used */}}
{{ if ne $m.kind "Namespace" }}
{{/* fix the index to be reversed as well */}}
{{ $i := sub (len $.Manifests) (add $i 1) }}
- op: delete
  path: {{ $i }}
{{ end }}
{{ end }}

{{ $namespace := .Namespace }}
{{/* generate one Knative Service per Workload */}}
{{ range $name, $spec := .Workloads }}
- op: set
  path: -1
  value:
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: {{ $name }}
      {{ if ne $namespace "" }}
      namespace: {{ $namespace }}
      {{ end }}
    spec:
      template:
        spec:
          containers:
            {{ range $contianerName, $container := $spec.containers }}
            - name: {{ $contianerName }}
              image: {{ $container.image }}
              {{- if and $container.command (gt (len $container.command) 0) }}
              command:
                {{- range $i, $cmd := $container.command }}
                - {{ $cmd }}
                {{ end }}
              {{ end }}
              {{- if and $container.args (gt (len $container.args) 0) }}
              args:
                {{- range $i, $arg := $container.args }}
                - {{ $arg }}
                {{ end }}
              {{ end }}
              {{- if and $container.variables (gt (len $container.variables) 0) }}
              env:
                {{- range $variableName, $variableValue := $container.variables }}
                - name: {{ $variableName }}
                  value: "{{ $variableValue }}"
                {{ end }}
              {{ end }}
              {{- if $container.resources }}
              resources:
                {{- if $container.resources.limits }}
                limits:
                  {{- if $container.resources.limits.memory }}
                  memory: {{ $container.resources.limits.memory }}
                  {{ end }}
                  {{- if $container.resources.limits.cpu }}
                  cpu: {{ $container.resources.limits.cpu }}
                  {{ end }}
                {{ end }}
                {{- if $container.resources.requests }}
                requests:
                  {{- if $container.resources.requests.memory }}
                  memory: {{ $container.resources.requests.memory }}
                  {{ end }}
                  {{- if $container.resources.requests.cpu }}
                  cpu: {{ $container.resources.requests.cpu }}
                  {{ end }}
                {{ end }}
              {{ end }}
              {{- if $container.livenessProbe }}
              livenessProbe:
                {{- if $container.livenessProbe.httpGet }}
                httpGet:
                  port: {{ $container.livenessProbe.httpGet.port }}
                  path: {{ $container.livenessProbe.httpGet.path }}
                {{ end }}
                {{- if $container.livenessProbe.exec }}
                exec:
                  command:
                  {{- range $command := $container.livenessProbe.exec.command }}
                  - {{ $command }}
                  {{ end }}
                {{ end }}
              {{ end }}
              {{- if $container.readinessProbe }}
              readinessProbe:
                {{- if $container.readinessProbe.httpGet }}
                httpGet:
                  port: {{ $container.readinessProbe.httpGet.port }}
                  path: {{ $container.readinessProbe.httpGet.path }}
                {{ end }}
                {{- if $container.readinessProbe.exec }}
                exec:
                  command:
                  {{- range $command := $container.readinessProbe.exec.command }}
                  - {{ $command }}
                  {{ end }}
                {{ end }}
              {{ end }}
            {{ end }}
{{ end }}
