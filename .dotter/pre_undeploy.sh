#!/usr/bin/env bash
trap 'exit' SIGINT
source .dotter/helpers/log.sh

{{#each pre_undeploy_scripts}}
# =============================================================================
# {{@this}}
# =============================================================================
{{include_template @this}}
{{/each}}
