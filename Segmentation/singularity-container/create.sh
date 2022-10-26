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
    exec sudo "$0" "$1" "$2" "$(which singularity)"
fi

# We are root, hooray!
if [ -z "$SINGULARITY_EXE" ]; then
    if [ -n "$3" ]; then
        SINGULARITY_EXE="$3"
    else
        SINGULARITY_EXE="$(which singularity)" ; rc=$?
        if [ $rc -ne 0 ]; then
            exit $rc
        fi
    fi
fi

# Build the container...
if [ ! -f "$1" ]; then
    "$SINGULARITY_EXE" build "$1" "$2" ; rc=$?
    if [ $rc -ne 0 ]; then
        exit $rc
    fi
fi

cat <<EOT
WARNING:  the Singularity container has been successfully created.  As a
          next step, you should sign-in to a remote repository, sign the
          container, and push it to the remote repository:

              singularity remote login

              singularity sign "$1"

              singularity push "$1" "library://[user]/[collection]/$1:[tag]"
                  where [tag] should be the version of this source, e.g.
                  "v1.0.0"

         Note that you may need to create a signing keypair prior to the
         second step.

EOT

