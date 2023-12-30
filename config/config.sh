#!/usr/bin/env bash
# shellcheck shell=bash

_context_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_context_dir/set_context.sh
source $_context_dir/get_context.sh
source $_context_dir/use_context.sh
source $_context_dir/../helpers/global.sh
source $_context_dir/../helpers/formatters.sh

function __usage_config {
    cat <<EOF
Usage: $BOILKUB_SCRIPT_NAME config [command] [options]

Commands:
    set-context <context-name> [options]:
        set new context or update it if already exists.
    get-contexts:
        retrieve contexts
    use-context <context-name>:
        change current context
EOF
}

function config_command_handler {
    local command="$1"
    shift
    case "$command" in
    config)
        case "$1" in
        set-context)
            # Check if the file exists
            if [ ! -f "$BOILKUBCONFIG" ]; then

                # Create the directory if it doesn't exist
                mkdir -p "$(dirname "$BOILKUBCONFIG")"

                # Output success message
                echo "Config file not found. Created a new one at $BOILKUBCONFIG"
                echo "contexts:" >"$BOILKUBCONFIG"
            fi
            shift
            set_context "$@" || {
                exit 1
            }
            exit 0
            ;;
        get-contexts)
            shift
            print_contexts_table || {
                exit 1
            }
            exit 0
            ;;
        use-context)
            shift
            use_context "$1" || {
                exit 1
            }
            exit 0
            ;;
        -h)
            __usage_config
            exit 0
            ;;
        *)
            error "Unknown command \`${1}\`"
            __usage_config
            exit 1
            ;;
        esac
        ;;
    esac
}
