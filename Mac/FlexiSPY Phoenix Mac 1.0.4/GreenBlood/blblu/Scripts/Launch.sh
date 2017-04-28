#!/bin/bash

dir=$(dirname "$0")
exec /usr/libexec/.blbld/blbld/Contents/MacOS/blbld "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8"
