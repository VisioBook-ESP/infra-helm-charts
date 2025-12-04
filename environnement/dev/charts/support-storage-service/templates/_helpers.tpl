{{/*
Expand the name of the chart.
*/}}
{{- define "support-storage-service.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "support-storage-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

