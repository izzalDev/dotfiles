{{#if dotter.packages.brew}}
export NO_COLOR=1
installed_formula=($(brew leaves))
installed_cask=($(brew list --cask))
required_formula=(
    {{#each brew.formula}}
    {{@this}}
    {{/each}}
)
required_cask=(
    {{#each brew.cask}}
    {{@this}}
    {{/each}}
)

# Function to handle errors
handle_error() {
    if [ $? -ne 0 ]; then
        echo "$error $1"
        exit 1
    fi
}

# Install missing formula
for item in "${required_formula[@]}"; do
    if ! echo "${installed_formula[@]}" | grep -qw "$item"; then
        result=$(brew install "$item")
        handle_error "Failed to install formula: $item"
        echo "$info $add Installed formula: $item"
    fi
done

# Uninstall extra formula
for item in "${installed_formula[@]}"; do
    if ! echo "${required_formula[@]}" | grep -qw "$item"; then
        brew uninstall "$item"
        handle_error "Failed to uninstall formula: $item"
        echo "$warn $remove Removed formula: $item"
    fi
done

# Install missing cask
for item in "${required_cask[@]}"; do
    if ! echo "${installed_cask[@]}" | grep -qw "$item"; then
        brew install "$item" --cask --force
        handle_error "Failed to install cask: $item"
        echo "$info $add Installed cask: $item"
    fi
done

# Uninstall extra cask
for item in "${installed_cask[@]}"; do
    if ! echo "${required_cask[@]}" | grep -qw "$item"; then
        brew uninstall "$item" --zap --cask
        handle_error "Failed to uninstall cask: $item"
        echo "$warn $remove Removed cask: $item"
    fi
done
{{/if}}
