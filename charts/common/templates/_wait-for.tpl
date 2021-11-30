{{- define "waitForUrl.init" }}
{{- if .url }}
{{- $retries := .retries | default "10" }}
{{- $isSemver := regexMatch "^[0-9.]+" .tasksVersion }}
{{- $tag := printf "%s%s" ($isSemver | ternary "v" "") .tasksVersion }}
- name: wait-for-init
  image: {{ printf "otomi/tasks:%s" $tag }}
  {{- include "common.resources" . | nindent 2 }}
  imagePullPolicy: {{ ternary "IfNotPresent" "Always" (regexMatch "^v\\d" $tag) }} 
  command: ["sh"]
  env:
    - name: WAIT_URL
      value: '{{ .url }}'
    - name: WAIT_OPTIONS
      value: '{"retries":{{ $retries }}}'
    {{- if ne .extraRootCA "" }}
    - name: NODE_EXTRA_CA_CERTS
      value: /etc/ssl/certs/ca-certificates.crt
    {{- end }}
  args:
    - '-c'
    - npm run tasks:wait-for
  securityContext:
    runAsUser: 1000
  volumeMounts:
    {{- if ne .extraRootCA "" }}
    {{- include "extraRootCA.volumeMounts" (dict "rootCA" .extraRootCA) | nindent 6 }}
    {{- end }}
{{- end }}
{{- end }}