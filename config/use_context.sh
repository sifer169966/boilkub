#!/usr/bin/env bash
# shellcheck shell=bash

source $_set_context_dir/../helpers/global.sh

function __usage_use_context {
    cat <<EOF

Usage: $BOILKUB_SCRIPT_NAME config use-context <context-name>
EOF
}

function use_context {
    local use_context="$1"
    if [[ -z "$use_context" || "$use_context" =~ ^[[:space:]]+$ || $(! is_valid_default_format "$use_context") ]]; then
        __usage_use_context 1>&2
        exit 1
    fi
    use_context="$use_context" yq --exit-status '.contexts[] | .name == strenv(use_context)' "$BOILKUBCONFIG" >/dev/null 2>&1 || {
        echo "error: could not find context '$use_context'" >&2
        exit 1
    }
    use_context="$use_context" yq -i '.current-context = strenv(use_context)' "$BOILKUBCONFIG" 1>/dev/null || {
        echo "error: could not use context $use_context" >&2
        exit 1
    }
    echo "Successfully, current-context is '$use_context'"
    exit 0
}
