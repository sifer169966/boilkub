#!/usr/bin/env bash
# shellcheck shell=bash
_set_context_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_set_context_dir/../helpers/global.sh

function usage_set_context {
    cat <<EOF

Usage: $BOILKUB_SCRIPT_NAME config set-context <context-name> --project-url=<project-url>
EOF
}

# Function to check if the name exists in the - context section of the YAML data
function is_context_exists() {
    local context_name="$1"
    context_name=$context_name yq eval --exit-status '.contexts[] | select(.name == strenv(context_name))' "$BOILKUBCONFIG" >/dev/null 2>&1 || {
        return 1
    }
    return 0
}

function update_or_insert_context {
    local context_name="$1"
    local project_url="$2"
    local exit_code=0
    if is_context_exists "$context_name"; then
        context_name=$context_name \
            project_url=$project_url \
            yq -i \
            '(.contexts[] | select(.name == strenv(context_name)) | .context.project-url)  = strenv(project_url)' \
            "$BOILKUBCONFIG" 1>/dev/null
        exit_code=$?
    else
        context_name=$context_name \
            project_url=$project_url \
            yq -i \
            '.contexts += [{"context": {"project-url": strenv(project_url)}, "name": strenv(context_name)}]' \
            "$BOILKUBCONFIG" 1>/dev/null
        exit_code=$?
    fi
    if [ "$exit_code" -ne 0 ]; then
        exit 1
    fi
    echo "Successfully, set context for '$context_name'"
    exit 0
}

# Function to set context
function set_context {
    local context_name="$1"
    shift
    local project_url=""

    while getopts ":-:" opt; do
        case "$opt" in
        -)
            case "${OPTARG}" in
            project-url=*)
                project_url="${OPTARG#*=}"
                ;;
            *)
                echo "Invalid option: --${OPTARG}"
                usage_set_context 1>&2
                exit 1
                ;;
            esac
            ;;
        *)
            echo "Invalid option: -$opt"
            usage_set_context 1>&2
            exit 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if the first argument is a valid YAML key and not empty
    if ! is_valid_default_format "$context_name"; then
        exit 1
    fi
    if ! update_or_insert_context "$context_name" "$project_url"; then
        exit 1
    fi
}
