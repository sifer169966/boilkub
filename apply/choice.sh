#!/usr/bin/env bash
# shellcheck shell=bash
_apply_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_apply_dir/../helpers/global.sh
source $_apply_dir/../helpers/formatters.sh
source $_apply_dir/../helpers/color.sh
source $_apply_dir/../helpers/table.sh

# Function to print YAML data as a table
function print_choice_table {
    local contexts="$1"
    # print headers
    col_choice_no_space=$(col_choice_no_space)
    col_name_space=$(col_name_space)
    __print_choice_table_header "$col_choice_no_space" "$col_name_space"
    choice_no=0
    while IFS=$'\t' read -r name project_url; do
        ((choice_no += 1))
        # obj=$(create_context_object "$name" "$project_url")
        # contexts+=("$obj")
        # contexts+=("${context[@]}")
        __print_choice_table_row "$col_choice_no_space" "$choice_no" "$col_name_space" "$name" "$project_url"
    done <<<"$contexts" || {
        exit 1
    }
    hr
}

: '
    Arguments:
        (context_amount)
'
function apply_context_from_stdin {
    local choice=$((0))
    local context_amount=$(($1))
    read -p "Enter your choice: " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        error "Invalid choice. The choice must be numeric"
        exit 1
    fi
    if [ $choice -le 0 ] || [ $choice -gt $context_amount ]; then
        error "Invalid choice. Please enter a valid choice no."
        exit 1
    fi
    echo $choice
    # Clear the current line

}

function apply_dest_from_stdin {
    read -p "Enter your destination: " dest
    regex_dir="^(\.|~?/)?([[:alnum:]_/\.\-]+)?$"
    regex_current_dir="^\.$"
    # Check if input does not match directory path format
    if [[ ! $dest =~ $regex_dir ]] && [[ ! $dest =~ $regex_current_dir ]]; then
        error "Invalid destination."
        exit 1
    fi
    echo "$dest"
}

: '
    Arguments:
        (col_choice_no_space col_name_sapce)
'
function __print_choice_table_header {
    # print headers
    local col_choice_no_space="$1"
    local col_name_sapce="$2"
    hr
    printf "${TXTWHT}%-${col_choice_no_space}s%-${col_name_sapce}s%-0s${TXTRST}\n" "$_COL_CHOICE_NO" "$_COL_NAME" "$_COL_TEMPLATE"
    hr
}

: '
    Arguments:
        (col_choice_no_space, choice_no, col_name_space, name)
'
function __print_choice_table_row {
    local col_choice_no_space="$1"
    local choice_no="$2"
    local col_name_space="$3"
    local name="$4"
    local project_url="$5"
    printf "${TXTYLW}%-${col_choice_no_space}s${TXTRST}${TXTGRN}%-${col_name_space}s${TXTRST}${TXTRED}%-0s${TXTRST}\n" "[$choice_no]" "$name" "$project_url"
}
