{{#if dotter.packages.ghostty}}
if ! ghostty --version >/dev/null; then
    echo "$error Ghostty is either not installed or not available in the PATH."
    exit 1
fi
{{/if}}
