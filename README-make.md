# Building and Installing on Linux

The contents of this source package — three Matlab programs and a Python program — have had a UNIX-style build system added in order to make deployment a tad easier.  Prerequisite software packages that must be present on the system and configured in the user's environment are:

- Matlab Compiler (MCR) 2017 or newer (we used R2018b)
- Singularity (for container build and execution)…
- …or an Anaconda or Intel Python distribution with the `conda` command avaiable

Due to binary incompatibility issues between our HPC clusters and the community versions of Tensorflow provided in conda and PyPI channels, the Singularity option is the default presented here.

## Prepare the Build Environment

First, decide where you want to install the software.  On our systems we use a hierarchical scheme for managing multiple versions/variants of software:

- All software is installed under `/opt/shared`
- This is the **drmaize** project **compvision**, so we will install all versions/variants we produce under `/opt/shared/drmaize/compvision`
- The programs are not versioned, so we will adopt a date-oriented versioning scheme of our own:  we are installing on September 15, 2022, so we will use `/opt/shared/drmaize/compvision/2022.09.15` as our installation root

With that knowledge, we can set

```
$ export PREFIX="/opt/shared/drmaize/compvision/2022.09.15"
```

in the environment so that the build system knows where the programs are destined to be installed.

As a base requirement the R2018b MCR software must be available in the environment.  On our HPC clusters, this is accomplished using VALET:

```
$ vpkg_require mcr/r2018b
```

Depending which build variants you choose for the **Segmentation** and **ThresholdAndSkeletonize** subprojects, additional software may be needed in the runtime environment:

- For Python virtualenv usage in either, add either an Anaconda or Intel Python packge to the environment:
    - `vpkg_require anaconda/2022.05`  or  `vpkg_require intel-oneapi/2022`
- For Singularity container usage, add
    - `vpkg_require singularity/default`


## Prepare the Makefile.inc

The top level of this source package includes a file named [Makefile.inc](./Makefile.inc) that defines some of the critical variables used by the build system:

| Variable | Discussion | Default |
| -------- | ---------- | ------- |
| `PREFIX` | The directory to which the products will be installed | the parent directory of the source code |
| `BINDIR` | The directory to which user-accessible executables will be installed | the `bin` directory under `PREFIX` |
| `LIBEXECDIR` | The directory to which supporting executables and other binary pieces will be installed | the `libexec` directory under `PREFIX` |
| `SEGMENTATION_BUILD_VARIANT` | The **Segmentation** subproject can be built as a `python-virtualenv` or a `singularity-container` | `singularity-container` |
| `SEGMENTATION_CONTAINER_ACTION` | The **Segmentation** `singularity-container` subproject can either download a pre-built container from the Sylabs cloud or build the container from scratch (root privileges required for the latter) | `download` |
| `THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT` | The **ThresholdAndSkeletonize** subproject can be delivered either as a Python `Scikit-Image` script or a Bash script that uses Fiji `ImageJ` | `ImageJ` |

The default value for each of these variables only applies when the shell environment (from which `make` was executed) lacks a variable of that name and a NAME=VALUE was not provided as an argument to the `make` command.  E.g. with a shell environment lacking all the variables

```
$ make PREFIX=/usr/local install
```

will install executables to `/usr/local/bin` and the Singularity container to `/usr/local/libexec`.


## Build/Install

With prior steps completed, `chdir` to the source package as the working directory before doing the following.

### Build (Compilation, Linking, etc.)

```
$ make
```

will kick-off the build of the **Segmentation** product first, followed by the three Matlab programs and finishing with the **ThresholdAndSkeletonize** product.

#### python-virtualenv

The `conda`-based Python variant includes no compilation phase (just installation).

#### singularity-container

Singularity requires root privileges to build a container image from a definition file.  If `SEGMENTATION_CONTAINER_ACTION` is set to `build` and the current user is not root, then `sudo` is used to execute the container build as root.

### Install

During installation the directory hierarchy under the selected `PREFIX` directory will be created and the products of the Build phase will be copied therein.

Note that the **Segmentation** subproject is installed first since the `conda` program (if the `python-virtualenv` variant is selected) prefers to install to an empty directory.  The executables produced in the Build phase will then be copied into the directory hierarchy already crated by `conda`.

Also note that depending on the value of `PREFIX` root privileges may be required:  installing to `/usr/local`, for example, would require that you either become root or use `sudo` to execute the command.

Since we set the `PREFIX` environment variable above, the installation is effected using

```
$ make install
```

When completed successfully, the `PREFIX` directory is populated thusly:

```
$ ls -l /opt/shared/drmaize/compvision/2022.09.15
/opt/shared/drmaize/compvision/2022.09.15:
total 34
drwxr-sr-x  2 frey swmgr  8 Oct 26 11:45 bin
drwxr-sr-x 13 frey swmgr 17 Oct 26 11:45 Fiji.app
drwxr-sr-x  2 frey swmgr  3 Oct 26 11:45 libexec

/opt/shared/drmaize/compvision/2022.09.15/bin:
total 576355
-rwxr-xr-x 1 frey swmgr  27681229 Oct 26 11:45 ConnectSkeleton
-rwxr-xr-x 1 frey swmgr     14233 Oct 26 11:45 imagej-filter
lrwxrwxrwx 1 frey swmgr        26 Oct 26 11:45 ImageJ-linux64 -> ../Fiji.app/ImageJ-linux64
-rwxr-xr-x 1 frey swmgr 281990576 Oct 26 11:45 QuantifyPhenotypes
-rwxr-xr-x 1 frey swmgr       322 Oct 26 11:45 SegmentObjects
-rwxr-xr-x 1 frey swmgr 281645174 Oct 26 11:45 SurfaceEstimation

/opt/shared/drmaize/compvision/2022.09.15/libexec:
total 640193
-rwxr-xr-x 1 frey swmgr 655611653 Oct 26 11:45 segmentation.sif
```

## Usage

To make use of the exectuables produced above, the runtime environment must have the same software packages configured (the same Matlab MCR and Singularity).  Again, on our HPC clusters this would entail the use of VALET (as cited above).  Rather than force every end user to remember what versions of MCR and Singularity to add, we can create a VALET package definition file for the software we just installed:

```
drmaize-compvision:
    prefix: /opt/shared/drmaize/compvision
    url: "https://github.com/drmaize/compvision"
    description: "Computer vision resources for the DR Maize project"

    default-version: "2022.09.15"

    versions:
        "2022.09.15":
            description: development build from v1.0.0 source
            attributes:
                Segmentation: Singularity container
                ThresholdAndSkeletonize: Bash wrapper to ImageJ
            actions:
                - variable: SINGULARITY_IMAGE
                  value: ${VALET_PATH_PREFIX}/libexec/segmentation.sif
            dependencies:
                - singularity/default
                - mcr/2018b
```

If you choose the Python virtualenv option for either the **Segmentation** or **ThresholdAndSkeletonize** 

To make use of the software, the runtime environment is configured simply with

```
$ vpkg_require drmaize-compvision/2022.09.15
Adding dependency `singularity/3.10.0` to your environment
Adding dependency `mcr/2018b` to your environment
Adding package `drmaize-compvision/2022.09.15` to your environment
```

which adds to the `PATH` so that the programs are found:

```
$ which SegmentObjects 
/opt/shared/drmaize/compvision/2022.09.15/bin/SegmentObjects

$ which SurfaceEstimation
/opt/shared/drmaize/compvision/2022.09.15/bin/SurfaceEstimation
```

In particular, the Singularity VALET package adds some default flags to map important file system paths into the container to make its usage as seemless as possible.  Since we used the `singularity-container` variant, the `SegmentObjects` command executes the Python script in a container but from the same working directory:

```
$ SegmentObjects --help
Using TensorFlow backend.
usage: SegmentObjects.py [-h] --input_path INPUT_PATH --output_path
                         OUTPUT_PATH --arch ARCH --weights WEIGHTS
                         [--normalize_factor NORMALIZE_FACTOR]
                         [--normalize_clip NORMALIZE_CLIP]

optional arguments:
  -h, --help            show this help message and exit
  --input_path INPUT_PATH, -i INPUT_PATH
                        Path to image to process
  --output_path OUTPUT_PATH, -o OUTPUT_PATH
                        Path to output to
  --arch ARCH, -a ARCH  Path to architecture of network in .json format, from
                        Keras
  --weights WEIGHTS, -w WEIGHTS
                        Path to weights of network in .h5 format, from Keras
  --normalize_factor NORMALIZE_FACTOR, -n NORMALIZE_FACTOR
                        Value to normalize input image by. We used 120 as that
                        was the mean of the dataset. If left blank, defaults
                        to image mean
  --normalize_clip NORMALIZE_CLIP, -nc NORMALIZE_CLIP
                        Is network trained on 0-1 or 0-255? For our trained
                        detectors, fungus is 255, while cells and stomata are
                        1
```
