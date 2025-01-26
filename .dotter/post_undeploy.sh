#!/usr/bin/env bash
source .dotter/helpers/log.sh

{{#each post_undeploy_scripts}}
# =============================================================================
# {{@this}}
# =============================================================================
{{include_template @this}}
{{/each}}
