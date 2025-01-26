#!/usr/bin/env bash
source .dotter/helpers/log.sh

{{#each pre_undeploy_scripts}}
# MARK: {{@this}}
{{include_template @this}}
{{/each}}
