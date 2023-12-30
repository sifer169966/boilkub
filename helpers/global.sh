#!/usr/bin/env bash
# shellcheck shell=bash
export BOILKUBCONFIG=~/.boilkub/config/config
export BOILKUB_SCRIPT_NAME=boilkub

function array_max_num {
    # Receive the array as "$@"
    local array=("$@")
    local max_num=0
    # Iterate through the array to find the maximum value
    for num in "${array[@]}"; do
        if ((num > max_num)); then
            max_num=$num
        fi
    done
    echo "$max_num"
}

# Function to print error messages for unknown options
print_unknown_option_error() {
    local flag=$1
    if [[ "$flag" != -* ]]; then
        printf "error: expected [options], but got '%s'\n\n" "$flag" >&2
    elif [[ "$flag" == ---* ]]; then
        printf "error: bad flag syntax: '%s'\n\n" "$flag" >&2
    elif [[ "$flag" == --* ]]; then
        printf "error: unknown flag: '%s'\n\n" "$flag" >&2
    elif [[ "$flag" == -* ]]; then
        printf "error: unknown shorthand flag: '%s'\n\n" "$flag" >&2
    fi
}

# Function to check if a string is in a valid YAML key format and not empty
function is_valid_default_format {
    local key="$1"
    if [[ ! "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]]; then
        echo "Invalid context name. Context name should be in a valid YAML key format"
        return 1
    fi
}
