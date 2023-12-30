#!/usr/bin/env bash
# shellcheck shell=bash
################################################################################
#
# Text formatters and manipulators
#
################################################################################
_helpers_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_helpers_dir/color.sh

hr() {
    local start=$'\e(0' end=$'\e(B' line='────────────────────────────────────────'
    local cols=${COLUMNS:-$(tput cols)}
    while ((${#line} < cols)); do line+="$line"; done
    printf '%s%s%s\n' "$start" "${line:0:cols}" "$end"
}

error() {
    local msg="$1"
    echo -e "${BLDRED}error: $msg${TXTRST}" 1>&2

}

warning() {
    local msg="$1"
    echo -e "${TXTYLW}$msg${TXTRST}"
}
