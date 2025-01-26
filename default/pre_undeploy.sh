{{#if (eq platform "Darwin")}}
pref_cache=".dotter/cache/preferences.txt"

if [ ! -f "$pref_cache" ]; then
    return 0
fi

while IFS= read -r pref; do
    IFS=" " read -r domain key type value <<< $pref

    result=$(defaults delete $domain $key 2>&1)
    if [ $? -ne 0 ]; then
        echo "$error Failed to remove preference for $domain $key"
        echo "$result"
        exit $?
    fi

    sed -i '' "/$pref/d" "$pref_cache"
    echo "$warn $remove Removed preference $domain $key $type $value"
done < $pref_cache
{{/if}}
