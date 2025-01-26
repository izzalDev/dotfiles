#!/usr/bin/env bash
trap 'exit' SIGINT
source .dotter/helpers/log.sh

{{#each post_deploy_scripts}}
# =============================================================================
# {{@this}}
# =============================================================================
{{include_template @this}}
{{/each}}
