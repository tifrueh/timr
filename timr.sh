#!/bin/sh

progname="$(basename $0)"

help="usage: ${progname} [ -q | --quiet ] <duration> [ <message> ] [ <urgency> ]

options:

    -h, --help          Show this help message.

    -q, --quiet         Don't print anything.

arguments:

    duration            The amount of time to wait (format HH+:MM:SS). As a
                        regular expression for the nerds:
                        [0-9][0-9]*:[0-5][0-9]:[0-5][0-9]

    message             The message to display in the notification (is passed
                        directly to notify-send(1)).

    urgency             The urgency to pass to notify-send(1).
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

# Check if we should be quiet.
if [ "$1" = "-q" -o "$1" = "--quiet" ]; then
    quiet=1
    shift
else
    quiet=0
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
now_time=$(date +%s)
end_time=$(( $now_time + $time_s ))

# Spin for the specified amount.
while rest_time=$(( $end_time - $(date +%s) )) && [ $rest_time -ge 0 ]; do
    [ $quiet -eq 1 ] && continue
    rest_time_hh=$(( $rest_time / 3600 ))
    rest_time_mm=$(( ($rest_time % 3600) / 60 ))
    rest_time_ss=$(( ($rest_time % 3600) % 60 ))
    printf "\r%$(( COLUMNS - 6 ))d:%02d:%02d" "$rest_time_hh" "$rest_time_mm" "$rest_time_ss"
    [ $rest_time -eq 0 ] && break
done

printf '\n'

# Notify the terminal.
tput bel

# Notify the desktop environment.
notify-send \
    --app-name="$progname" \
    --urgency="$urg" \
    --icon=clock \
    "timr" \
    "$msg"
