#!/bin/bash

# Exit when a command fails
set -o errexit

# Error when unset variables are found
set -o nounset

NAME=DefaultSecurityBrowser@mozilla.doslash.org

cd DefaultSecurityBrowser
zip -r $NAME.xpi *









