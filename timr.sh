#!/bin/sh

progname="$(basename $0)"

help="usage: ${progname} <duration> [ <message> ] [ <urgency> ]

options:
    duration    The amount of time to wait (format HH+:MM:SS).
                As a regular expression for the nerds:
                [0-9][0-9]*:[0-5][0-9]:[0-5][0-9]
    message     The message to display in the notification (is passed directly to notify-send(1)).
    urgency     The urgency to pass to notify-send(1).
"

time_regex='[0-9][0-9]*:[0-5][0-9]:[0-5][0-9]'
time_hh_regex='\([0-9][0-9]*\):[0-5][0-9]:[0-5][0-9]'
time_mm_regex='[0-9][0-9]*:\([0-5][0-9]\):[0-5][0-9]'
time_ss_regex='[0-9][0-9]*:[0-5][0-9]:\([0-5][0-9]\)'

# Display help if number of options isn't correct.
if [ $# -lt 1 -o $# -gt 3 ]; then
    printf '%s' "$help"
    exit 1
fi

# Display help if requested.
if [ "$1" = "-h" -o "$1" = "--help" ]; then
    printf '%s' "$help"
    exit 0
fi

# Test if time format is correct.
if ! expr "$1" : "$time_regex" 1> /dev/null 2>&1; then
    printf 'error: expected time format HH+:MM:SS, got %s\n' "$1"
    exit 1
fi

# Use default message if none provided.
if [ $# -gt 1 ]; then
    msg="$2"
else
    msg="${1} has run out!"
fi

# Use normal urgency if none provided.
if [ $# -gt 2 ]; then
    urg="$3"
else
    urg="normal"
fi

# Calculate time in seconds.
time_hh=$( expr "$1" : "$time_hh_regex" )
time_mm=$( expr "$1" : "$time_mm_regex" )
time_ss=$( expr "$1" : "$time_ss_regex" )
time_s=$(( $time_ss + 60*$time_mm + 3600*$time_hh ))
printf 'sleeping for %ds\n' "$time_s"

# Sleep for the specified amount.
sleep $time_s

# Notify the terminal.
tput bel

# Notify the desktop environment.
notify-send \
    --app-name="$progname" \
    --urgency="$urg" \
    --icon=clock \
    "timr" \
    "$msg"
