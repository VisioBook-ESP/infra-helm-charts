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

{{- define "support-storage-service.labels" -}}
helm.sh/chart: {{ include "support-storage-service.chart" . }}
{{ include "support-storage-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "support-storage-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "support-storage-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "support-storage-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}