{{- define "content-ingestion-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "content-ingestion-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "content-ingestion-service.name" . | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "content-ingestion-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "content-ingestion-service.labels" -}}
helm.sh/chart: {{ include "content-ingestion-service.chart" . }}
{{ include "content-ingestion-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "content-ingestion-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "content-ingestion-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "content-ingestion-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "content-ingestion-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}