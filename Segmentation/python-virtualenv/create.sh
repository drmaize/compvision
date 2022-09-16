#!/bin/bash
#
# Create the conda Python virtual environment for the Segmentation program.
#

FORCE_INSTALL=0

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            cat <<EOT
usage:

    $0 {options}

  options:

    -h/--help              show this information
    -P/--prefix <PATH>,    directory to which the new conda environment should be
       --prefix=<PATH>     installed
    -f/--force             force reinstallation of the environment

EOT
            exit 0
            ;;
        -P|--prefix)
            if [ $# -eq 1 ]; then
                echo "ERROR:  no value provided with $1"
                exit 22
            fi
            shift
            PREFIX="$1"
            ;;
        --prefix=*)
            if [[ ! $1 =~ ^--prefix=(.*)$ ]]; then
                echo "ERROR:  invalid option: $1"
                exit 22
            fi
            PREFIX="${BASH_REMATCH[1]}"
            ;;
        -f|--force)
            FORCE_INSTALL=1
            ;;
        *)
            echo "ERROR:  unknown option: $1"
            exit 22
            ;;
    esac
    shift
done

# If we have no PREFIX, we can't do much:
if [ -z "$PREFIX" ]; then
    echo "ERROR:  no installation prefix provided"
    exit 1
fi

vpkg_require intel-oneapi/2022

# Attempt to activate it first -- if it works, then we don't need to do this again
if [ $FORCE_INSTALL -eq 0 ]; then
    conda activate "$PREFIX" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        cat <<EOT
NOTICE:  virtual environment in $PREFIX already usable; you can
         force a reinstallation using the -f/--force flag
EOT
        exit 0
    fi
fi

conda create --prefix="$PREFIX" --channel=intel python=3.6 pip numpy=1.19 Keras=2.0.8
rc=$?
if [ $rc -eq 0 ]; then
    conda activate "$PREFIX"
    rc=$?
    if [ $rc -eq 0 ]; then
        pip install imageio==2.9 tifffile==2020.9.3 scikit_image==0.17.2
        rc=$?
    fi
fi
exit $rc

