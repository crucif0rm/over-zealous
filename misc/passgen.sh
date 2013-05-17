#!/bin/bash
#
# Generate a random password
# default=12

if [ -n "$1" ]; then

let "RAND=$1"

echo "PASSWORD: `dd if=/dev/urandom count=100 2> /dev/null | sha1sum -b - | head -c $RAND; echo ""`"

elif [ -z "$1" ]; then

echo "PASSWORD: `dd if=/dev/urandom count=100 2> /dev/null | sha1sum -b - | head -c 12; echo ""`"

exit 0
fi
