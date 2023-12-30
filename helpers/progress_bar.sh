#!/usr/bin/env bash
# shellcheck shell=bash

_temp_current_progress_file=/tmp/boilkub_current_progress
_temp_progress_frame_file=/tmp/boilkub_progress_frame
_temp_stop_progress_bar_file=/tmp/boilkub_stop_progress_bar

function exit_progress_bar {
    __create_stop_progress_bar
    rm -rf $_temp_progress_frame_file $_temp_current_progress_file
    tput cnorm
    echo
}

trap 'exit_progress_bar' EXIT
trap 'exit_progress_bar; exit 1' TERM INT HUP

# Function to draw the progress bar
draw_progress_bar() {
    local terminal_width=50
    local percentage=$1
    local num_chars=$(((percentage * terminal_width) / 100))

    # Set the terminal color to green
    tput setaf 2

    # Draw the progress bar
    printf "["
    for ((i = 0; i < num_chars; i++)); do
        printf "="
    done
    for ((i = num_chars; i < terminal_width; i++)); do
        printf " "
    done
    printf "] %d%%" "$percentage"
    # Reset the terminal color
    tput sgr0
}

function set_current_progress {
    echo "$1" >$_temp_current_progress_file
}

function set_progress_frame {
    echo "$1" >$_temp_progress_frame_file
}

function __create_stop_progress_bar {
    touch $_temp_stop_progress_bar_file
}

function is_stop_progress_bar {
    if [ -f $_temp_stop_progress_bar_file ]; then
        return 0
    fi
    return 1
}

function init_new_progress_bar {
    rm -rf $_temp_progress_frame_file $_temp_current_progress_file
    set_progress_frame 0
    set_current_progress 0
}

_max_progress=100
# Function to run the progress bar loop
run_progress_bar() {
    rm -rf $_temp_stop_progress_bar_file
    local current_progress=0
    local progress_frame=0
    # hide cursor
    tput civis
    while ! is_stop_progress_bar; do
        if [ -f $_temp_current_progress_file ]; then
            current_progress=$(<$_temp_current_progress_file)
        fi
        if [ -f $_temp_progress_frame_file ]; then
            progress_frame=$(<$_temp_progress_frame_file)
        fi
        if [ $current_progress -lt $progress_frame ]; then
            ((current_progress += 1))
            set_current_progress $((current_progress))
        fi
        sleep 0.02
        # Update the progress bar
        draw_progress_bar $current_progress
        echo -ne "\r"
        if [ $current_progress -ge $_max_progress ]; then
            break
        fi
    done
}
