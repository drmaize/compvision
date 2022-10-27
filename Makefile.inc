##
## Variables used by all subprojects' Makefiles.  All but the
## SOURCE_DIR can be overridden by setting an environment variable
## of the same name before running the "make" command.
##

# In what directory does this source code reside:
SOURCE_DIR	:= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Default installation root is the parent directory of the source code:
PREFIX		?= $(abspath $(SOURCE_DIR)/..)

# Other directories under the installation root:
BINDIR		?= $(PREFIX)/bin
LIBEXECDIR	?= $(PREFIX)/libexec

# The default Segmentation build variant:
SEGMENTATION_BUILD_VARIANT ?= singularity-container

# Should we "build" or "download" the container (if selected)?
SEGMENTATION_CONTAINER_ACTION ?= download

# The ThresholdAndSkeletonize build variant, "ImageJ" or "Scikit-Image"
THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT ?= ImageJ

