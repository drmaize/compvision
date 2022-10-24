#!/bin/bash
#
# Wrapper script to generate the Singularity container for this
# Python program.
#

if [ "$(id -u)" -ne 0 ]; then
    cat <<EOT
WARNING:  creation of a Singularity image from a definition file
          requires root privileges -- let's try 'sudo'
EOT
    exec sudo "$(which singularity)" build "$1" "$2"
fi

# We are root, hooray:
exec singularity build "$1" "$2"

