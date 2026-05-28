{{/* Create gomplate specific iteration over versions array */}}
{{- range $version := .versions -}}
  {{- $ctx := dict "latest" $.latest "version" $version }}

  {{/* Define paths to render the Dockerfiles to */}}
  {{- $outPath := printf "dockerfiles/%s/compose.yaml" $version.slug }}

  {{/* Render the inline template defined below */}}
  {{- tmpl.Exec "composefile" $ctx | file.Write $outPath }}
{{- end -}}

{{- define "composefile" -}}
################################################################
#                                                              #
#  WARNING: THIS FILE IS AUTO-GENERATED. DO NOT EDIT MANUALLY  #
#                                                              #
################################################################

name: open-integration-engine

{{/* Assign current version slug into a variable to carry it into the tags iteration */}}
{{- $slug := .version.slug -}}
services:
  {{- range .version.tags }}
    {{ print .distro "-" .type ":" }}
      image: brightcodecompany/openintegrationengine
      build:
        target: {{ .distro }}-{{ .type }}
        context: .
        platforms:
          - linux/amd64
          - linux/arm64
        tags:
          - brightcodecompany/openintegrationengine:{{ $slug }}-{{ .distro }}
          - brightcodecompany/openintegrationengine:{{ $slug }}-{{ .distro }}-{{ .type }}
          {{- if eq $slug $.latest }}
          - brightcodecompany/openintegrationengine:latest-{{ .distro }}-{{ .type }}
            {{- if eq .type "jre" }}
          - brightcodecompany/openintegrationengine:latest-{{ .distro }}
              {{- if eq .distro "alpine" }}
          - brightcodecompany/openintegrationengine:latest
              {{- end }}
            {{- end }}
          {{- end }}
  {{ end }}
{{- end }}
