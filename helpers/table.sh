#!/usr/bin/env bash
# shellcheck shell=bash

_COL_CHOICE_NO="CHOICE_NO"
_COL_NAME="NAME"
_COL_TEMPLATE="TEMPLATE"

function get_space {
    local base=3
    local default=$(($1 + $base))
    local comparer=$(($2 + $base))
    if [ $comparer -le $default ]; then
        echo $default
        return 0
    fi
    echo $comparer
    return 0
}

function col_name_space {
    local array_buffer=()
    # get the maximum number of the length of `name:` value
    name_lengths=$(yq -o=props '.contexts[] | .name | length' "$BOILKUBCONFIG") || {
        exit 1
    }
    while IFS= read -r line; do
        array_buffer+=("$line")
    done <<<"$name_lengths" || {
        exit 1
    }
    max_length_name=$(array_max_num "${array_buffer[@]}")
    # delcare default space on the right side of `$_COL_NAME` header by couting the length of `NAME`
    default_name_space=$(echo -n "$_COL_NAME" | wc -c)
    # get space on the right side of `$_COL_NAME` header
    space=$(get_space "$default_name_space" "$max_length_name")
    echo $space
}

function col_current_space {
    # delcare default space on the right side of `CURRENT` header by couting the length of `CURRENT`
    default_current_space=$(echo -n "CURRENT" | wc -c)
    # get space on the right side of `CURRENT` header, `1` is stands for length of `*`
    space=$(get_space $default_current_space 1)
    echo "$space"
}

function col_choice_no_space {
    contexts_length=$(yq '.contexts | length' "$BOILKUBCONFIG") || {
        exit 1
    }
    max_length_choice_no=$(echo -n "$contexts_length" | wc -c)
    # delcare default space on the right side of `$_COL_CHOICE_NO` header by couting the length of `$_COL_CHOICE_NO`
    default_choice_no_space=$(echo -n "$_COL_CHOICE_NO" | wc -c)
    # get space on the right side of `$_COL_CHOICE_NO` header, + 2 is reserved for `[` and `]` from `[1]` of the table output
    space=$(get_space $default_choice_no_space $((max_length_choice_no + 2)))
    echo $space
}
