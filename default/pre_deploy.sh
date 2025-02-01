{{#if (eq platform "Darwin")}}
echo {{concat " " platform "halo"}}
pref_cache=".dotter/cache/preferences.txt"

if [ ! -f "$pref_cache" ]; then
    touch "$pref_cache"
fi

current_pref=(
{{#each preferences as |items domain|}}
{{#each items}}
"{{domain}} {{key}} {{type}} {{value}}"
{{/each}}
{{/each}}
)

for pref in "${current_pref[@]}"; do
    if grep -q "$pref" "$pref_cache"; then
        continue
    fi

    IFS=" " read -r domain key new_type new_value <<< "$pref"
    old_pref=$(grep "$domain $key" "$pref_cache")

    if [ -n "$old_pref" ]; then
        IFS=" " read -r _ _ old_type old_value <<< "$old_pref"
    fi

    result=$(defaults write "$domain" "$key" "-$new_type" "$new_value" 2>&1)
    if [ $? -ne 0 ]; then
        echo "$error Failed to write preference for $domain $key"
        echo "$result"
        exit $?
    fi

    if [ -z "$old_type" ] || [ -z "$old_value" ]; then
        echo "$info $add Added preference $domain $key: $new_value"
        echo "$pref" >> "$pref_cache"
        [ "$domain" == "com.apple.dock" ] && dock_changed=true
    elif [ "$old_type $old_value" != "$new_type $new_value" ]; then
        echo "$info $change Changed preference $domain $key: $old_value -> $new_value"
        sed -i '' "s/$old_pref/$pref/" $pref_cache
        [ "$domain" == "com.apple.dock" ] && dock_changed=true
    fi
done

while IFS= read -r pref; do
    IFS=" " read -r domain key type value <<< $pref
    if echo "${current_pref[@]}" | grep -q "$pref"; then
        continue
    fi

    if ! defaults read $domain $key; then
        continue
    fi

    if ! defaults delete $domain $key 2>&1; then
        echo "$error Failed to remove preference for $domain $key"
        echo "$result"
        exit $?
    fi

    [ "$domain" == "com.apple.dock" ] && dock_changed=true

    sed -i '' "\|$pref|d" "$pref_cache"
    echo "$warn $remove Removed preference $domain $key $type $value"
done < $pref_cache

if [ "$dock_changed" = true ]; then
    killall Dock
fi
{{/if}}

{{#each packages}}
{{#if this.items}}
if ! command -v {{this.list_cmd}} &>/dev/null; then
    echo "$error Failed to migrate packages from {{@key}}."
    echo "{{@key}} is either not installed or not available in the PATH."
    exit 1
fi

pkg_cache=".dotter/cache/{{@key}}.txt"
if [[ ! -f $pkg_cache ]]; then
    touch $pkg_cache
fi
installed_packages=$({{this.list_cmd}})
required_packages=(
    {{#each this.items}}
    "{{this}}"
    {{/each}}
)

# Install missing packages
for package in "${required_packages[@]}"; do
    if echo "$installed_packages" | grep -qw "$package"; then
        continue
    fi
    if grep -qw "$package" "$pkg_cache"; then
        continue
    fi
    if ! {{this.install_cmd}} $package; then
        echo "$error Failed to install $package from {{@key}}"
        exit $?
    fi
    echo "$info $add Installed $package to {{@key}}"
    echo "$package" >> "$pkg_cache"
done

# Uninstall extra packages
while IFS= read -r package; do
    if echo "${required_packages[@]}" | grep -qw "$package"; then
        continue
    fi
    if ! {{this.uninstall_cmd}} "$package"; then
        echo "$error Failed to remove $package from $key"
        exit $?
    fi
    echo "$warn $remove Removed $package from {{@key}}"
    sed -i '' "\|$package|d" "$pkg_cache"
done < $pkg_cache
{{/if}}
{{/each}}
