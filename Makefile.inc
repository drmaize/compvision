#
# Common pieces used by sub-projects:
#

# Where's the source code residing:
SOURCE_DIR	:= $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Installation root:
PREFIX		?= $(abspath $(SOURCE_DIR)/..)

# Other directories under the root:
BINDIR		?= $(PREFIX)/bin
SBINDIR		?= $(PREFIX)/sbin
LIBDIR		?= $(PREFIX)/lib
LIBEXECDIR	?= $(PREFIX)/libexec

