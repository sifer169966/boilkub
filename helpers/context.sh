#!/usr/bin/env bash
# shellcheck shell=bash

: '
access value by using
while IFS=$'\t' read -r name project_url; do ...
'
function retrieve_contexts {

    contexts=$(yq '.contexts[] | .context as $c | .name as $n | [$n, $c."project-url"] | @tsv' "$BOILKUBCONFIG") || {
        exit 1
    }

    echo "$contexts"
}

: '
retrive value by using
IFS=$'\t' read -r name project_url <<<"$variable"
'
function retrieve_current_context {
    current_context=$(yq '.current-context as $cc | .contexts[] | select(.name == $cc) | .name as $n | .context as $c | [$n, $c."project-url"] | @tsv' "$BOILKUBCONFIG") || {
        exit 1
    }
    echo "$current_context"
    exit 0
}

function create_context_object {
    local name="$1"
    local project_url="$2"
    local object=("$name" "$project_url")
    echo "${object[*]}"
}
