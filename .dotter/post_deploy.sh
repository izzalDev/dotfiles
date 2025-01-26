#!/usr/bin/env bash
source .dotter/helpers/log.sh

{{#each post_deploy_scripts}}
# MARK: {{@this}}
{{include_template @this}}
{{/each}}
