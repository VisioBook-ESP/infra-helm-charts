{{/*
Expand the name of the chart.
*/}}
{{- define "ai-analysis-service.name" -}}
{{ .Chart.Name }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ai-analysis-service.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "ai-analysis-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
