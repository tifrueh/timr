#!/bin/sh

progname="$(basename $0)"

help="usage: ${progname} <time> [ <message> ] [ <urgency> ]

options:
    time        The amount of time to wait before sending the notification (is
                passed directly to sleep(1)).
    message     The message to display in the notification (is passed directly to notify-send(1)).
    urgency     The urgency to pass to notify-send(1).
"

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

# Use default message if none provided.
if [ $# -gt 1 ]; then
    msg="$2"
else
    msg="Your timer of ${1} has run out!"
fi

# Use normal urgency if none provided.
if [ $# -gt 2 ]; then
    urg="$3"
else
    urg="normal"
fi

# Sleep for the specified amount.
sleep $1

# Notify the terminal.
tput bel

# Notify the desktop environment.
notify-send \
    --app-name="$progname" \
    --urgency="$urg" \
    --icon=clock \
    "timr" \
    "$msg"
