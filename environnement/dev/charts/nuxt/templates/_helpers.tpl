{{/*
Expand the name of the chart.
*/}}
{{- define "nuxt.name" -}}
{{- /* order: name > nameOverride > Chart.Name */ -}}
{{- $base := coalesce .Values.name .Values.nameOverride .Chart.Name -}}
{{- $base | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nuxt.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.name -}}
{{- /* if 'name' is provided, use it as the full name (no release prefix) */ -}}
{{- .Values.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nuxt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nuxt.labels" -}}
helm.sh/chart: {{ include "nuxt.chart" . }}
{{ include "nuxt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nuxt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nuxt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nuxt.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nuxt.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
