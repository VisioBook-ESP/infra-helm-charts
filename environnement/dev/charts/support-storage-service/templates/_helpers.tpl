{{/*
Expand the name of the chart.
*/}}
{{- define "support-storage-service.name" -}}
{{ .Chart.Name }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "support-storage-service.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "support-storage-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
