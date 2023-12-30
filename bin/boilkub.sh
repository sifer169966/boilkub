#!/usr/bin/env bash
# shellcheck shell=bash
_ROOT_PROJECT=
_VERSION="VERSION_PLACEHOLDER"
_SOURCE="SOURCE_PLACEHOLDER"
source $_ROOT_PROJECT/helpers/color.sh
source $_ROOT_PROJECT/helpers/formatters.sh
source $_ROOT_PROJECT/helpers/global.sh
source $_ROOT_PROJECT/config/config.sh
source $_ROOT_PROJECT/apply/apply.sh

# Function to display script usage
function __usage_boilkub {
    cat <<EOF

Usage: $BOILKUB_SCRIPT_NAME [command|option]

Commands:
    config:
        see more detail '$BOILKUB_SCRIPT_NAME config -h'.
    apply:
        see more detail '$BOILKUB_SCRIPT_NAME apply -h'.
Options:
    -h:
        help
    --version:
        print version information
EOF
}

command="$1"

if [[ "$command" == "config" ]]; then
    config_command_handler "$@" || {
        exit 1
    }
    exit 0
fi

# handle init command
if [[ "$command" == "apply" ]]; then
    apply_command_handler "$@" || {
        exit 1
    }
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h)
        __usage_boilkub
        exit 0
        ;;
    --version)
        cat <<EOF
$BOILKUB_SCRIPT_NAME version $_VERSION from source ($_SOURCE)
EOF
        exit 0
        ;;
    *)
        echo "error: unknown argument" 1>&2
        __usage_boilkub 1>&2
        exit 1
        ;;
    esac
done
