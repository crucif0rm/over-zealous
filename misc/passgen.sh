#!/bin/bash
#
#Copyright 2013 Matthew Martinez
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
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
