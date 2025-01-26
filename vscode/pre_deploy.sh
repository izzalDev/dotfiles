{{#if dotter.packages.vscode}}
if ! command -v code >/dev/null; then
    echo "$error Failed to migrate Visual Studio Code extensions."
    echo "Visual Studio Code is either not installed or not available in the PATH."
    exit 1
fi

installed_extensions=$(code --list-extensions)
required_extensions=(
    {{#each vscode.extensions}}
    {{@this}}
    {{/each}}
)

# Install missing extensions
for extension in "${required_extensions[@]}"; do
    if ! echo "$installed_extensions" | grep -qw "$extension"; then
        echo "$info $add Installing vscode $extension extension"
        code --install-extension "$extension"
    fi
done

# Uninstall extra extensions
for extension in "${installed_extensions[@]}"; do
    if ! echo "${required_extensions[@]}" | grep -qw "$extension"; then
        echo "$warn $remove Uninstalling vscode $extension extension"
        code --uninstall-extension "$extension"
    fi
done
{{/if}}
