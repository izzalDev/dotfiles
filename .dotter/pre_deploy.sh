#!/usr/bin/env bash
trap 'exit' SIGINT
source .dotter/helpers/log.sh

{{#if (eq platform "Darwin")}}
# =============================================================================
# Homebrew installation
# =============================================================================
# Install Homebrew if not already present
if ! command -v brew &>/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to zprofile if not already configured
if ! grep -q "$(/opt/homebrew/bin/brew shellenv)" ~/.zprofile; then
  echo "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zprofile
fi

# Load Homebrew environment (optional, can be placed in your shell rc file)
eval "$(/opt/homebrew/bin/brew shellenv)"
{{/if}}

{{#each pre_deploy_scripts}}
# =============================================================================
# {{@this}}
# =============================================================================
{{include_template @this}}
{{/each}}
