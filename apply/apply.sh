#!/usr/bin/env bash
# shellcheck shell=bash
_apply_dir="$(dirname "${BASH_SOURCE[0]}")"
source $_apply_dir/../helpers/global.sh
source $_apply_dir/../helpers/formatters.sh
source $_apply_dir/../helpers/color.sh
source $_apply_dir/../helpers/context.sh
source $_apply_dir/../helpers/progress_bar.sh
source $_apply_dir/choice.sh

_progress_bar_pid=
_temp_repo="/tmp/$BOILKUB_SCRIPT_NAME/temp_repo"

function __exit_apply {
    exit_progress_bar
    rm -rf $_temp_repo
}

trap '__exit_apply' EXIT

trap '__exit_apply; exit 1' TERM INT HUP

function __usage_apply {
    cat <<EOF
Usage: 
    $BOILKUB_SCRIPT_NAME apply
    $BOILKUB_SCRIPT_NAME apply [options]

Options:
    -d <destination>:
        specify the destination where the package will be placed.
        **NOTE:** if provided this option it gonna apply current-context instead of prompted to enter a choice
    -y:
        skip prompt up when it found the existing directory for placing the package.
        **NOTE** If there is duplicated name, it gonna replace that file or directory.
EOF
}

function __apply {
    local name="$1"
    local project_url="$2"
    local dest
    dest="$(eval echo "$3")"
    local is_yes="$4"
    dest=$(eval echo "$dest")
    dest=$(echo "$dest" | sed 's#/*$##')
    if [[ -z "$dest" ]]; then
        dest="."
    elif [[ "$dest" =~ ^[[:space:]]+$ ]]; then
        error "String contains only whitespace characters"
        exit 1
    fi
    if [[ -d $dest && "$is_yes" -eq 1 ]]; then
        warning "Directory already exists. Do it anyway? [y/n]"
        read -r response
        if [ "$response" = "n" ]; then
            exit 0
        fi
    fi
    echo -en "${BLDGRN}Apply \`$name\` to \`$dest${TXTRST}\`\n"

    run_progress_bar &
    progress_bar_pid=$!
    init_new_progress_bar

    progress_frame=60
    set_progress_frame $progress_frame

    rm -f "$_temp_repo"
    # Clone the GitLab repository
    err=$(git clone "$project_url" "$_temp_repo" 2>&1 1>/dev/null)
    if [ $? -ne 0 ]; then
        error "$err"
        exit 1
    fi
    set_current_progress $progress_frame

    progress_frame=70
    set_progress_frame $progress_frame
    # create new directory for destionation if not exists
    if [ ! -d "$dest" ]; then
        err=$(mkdir -p "$dest" 2>&1 1>/dev/null)
        if [ $? -ne 0 ]; then
            error "$err"
            exit 1
        fi
    fi
    set_current_progress $progress_frame

    progress_frame=100
    set_progress_frame $progress_frame
    local backup_directory
    backup_directory="$(eval echo ~/.Trash/"${BOILKUB_SCRIPT_NAME}_$(date +%s)")"
    is_backup_created=1
    for entry in "$_temp_repo"/*; do
        filename=$(basename "$entry")
        if [[ "$filename" == ".git"* ]]; then
            continue
        fi
        # backup existing destination to ~/.Trash
        if [ -e "$dest/$filename" ]; then
            if [ $is_backup_created -eq 1 ]; then
                mkdir -p "$backup_directory"
                is_backup_created=0
            fi
            mv "$dest/$filename" "$backup_directory/"
        fi
        err=$(mv -f "$entry" "$dest" 2>&1 1>/dev/null)
        if [ $? -ne 0 ]; then
            error "$err"
            exit 1
        fi

    done
    set_current_progress $progress_frame
    wait "$progress_bar_pid"
    exit 0
}

function apply_command_handler {
    shift
    local dest="$1"
    # default is false
    local is_option=1
    # default is false
    local is_yes=1
    local project_url=""
    local name=""
    while [[ $# -gt 0 ]]; do
        is_option=0
        case "$1" in
        -d)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "option -d requires an argument." >&2
                __usage_apply 1>&2
                exit 1
            fi
            dest="$2"
            shift 2
            ;;
        -y)
            is_yes=0
            shift
            ;;
        -h)
            __usage_apply
            exit 0
            ;;
        *)
            print_unknown_option_error "$1"
            __usage_apply 1>&2
            exit 1
            ;;
        esac
    done

    if [ $is_option -eq 1 ]; then
        local contexts_tsv=""
        contexts_tsv=$(retrieve_contexts)
        declare -a contexts
        printf "Available options:\n"
        print_choice_table "$contexts_tsv"
        while IFS=$'\t' read -r name project_url; do
            obj=$(create_context_object "$name" "$project_url")
            contexts+=("$obj")
        done <<<"$contexts_tsv" || {
            exit 1
        }

        choice=$(apply_context_from_stdin "${#contexts[@]}") || {
            exit 1
        }
        tput cuu1 # Move cursor up by 1 line
        tput el
        ((choice -= 1))
        IFS=' ' read -r -a properties <<<"${contexts[$choice]}"
        name="${properties[0]}"
        project_url="${properties[1]}"
        dest="$(apply_dest_from_stdin)" >&2 || {
            exit 1
        }
        tput cuu1 # Move cursor up by 1 line
        tput el
    else
        current_context=$(retrieve_current_context) || {
            exit 1
        }
        IFS=$'\t' read -r name project_url <<<"$current_context"
    fi

    __apply "$name" "$project_url" "$dest" "$is_yes" 2>&1 || {
        exit 1
    }
    exit 0
}
