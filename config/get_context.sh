#!/usr/bin/env bash
# shellcheck shell=bash
_get_context_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_get_context_dir/../helpers/table.sh

# Function to print YAML data as a table
function print_contexts_table {
    col_current_space=$(col_current_space)
    col_name_space=$(col_name_space)
    # print headers
    printf "%-${col_current_space}s %-${col_name_space}s %-0s\n" "CURRENT" "NAME" "TEMPLATE"
    # retrieve currenct context
    current_context=$(yq '.current-context' "$BOILKUBCONFIG") || {
        exit 1
    }
    # print rows of content
    contexts=$(yq '.contexts[] | .context as $c | .name as $n | [$n, $c."project-url"] | @tsv' "$BOILKUBCONFIG") || {
        exit 1
    }
    while IFS=$'\t' read -r name project_url; do
        current=""
        if [ "$current_context" = "$name" ]; then
            current="*"
        fi
        printf "%-${col_current_space}s %-${col_name_space}s %-0s\n" "$current" "$name" "$project_url"
    done <<<"$contexts" || {
        exit 1
    }
    exit 0
}
