##
## Template Makefile for MCR projects
## Variable setup
##
## $Id: Makefile 645 2018-04-09 18:53:19Z frey $
##

# What Matlab Compiler should we use?
VALET_PACKAGES		= mcr/2018b

# What is the name of the executable to be produced:
TARGET			= SurfaceEstimation

# List all source (.m) files that must be compiled to
# produce the TARGET; one or more per line with a trailing
# space-backslash sequence -- " \" -- at the end of each
# line:
SOURCES			= SurfaceEstimation.m

# What runtime options should be used for the compiled
# Matlab code?
#
# Drop the -singleCompThread if you _want_ the resulting
# executable to have threaded math library support -- you'll
# want to submit such jobs with the "exclusive=1" flag to
# ensure your program has the whole node to itself!
#
MCR_RUNTIME_FLAGS	= "-nojvm,-nodesktop,-singleCompThread"

##
####
####
##

# Import the standard build rules:
include /opt/shared/valet/templates/Makefiles/MCR.rules

# Add any of your own special build rules after this line.  For simple
# projects, none should be necessary.
-include ../Makefile.inc

install: $(TARGET) $(BINDIR)
	install $(TARGET) $(BINDIR)

-include ../Makefile.rules.post

