##
## Produce a binary executable from the Matlab code in this
## directory.
##

# What is the name of the executable to be produced:
TARGET			= ConnectSkeleton

# List all source (.m) files that must be compiled to
# produce the TARGET; one or more per line with a trailing
# space-backslash sequence -- " \" -- at the end of each
# line:
SOURCE			= ConnectSkeleton.m

# What runtime options should be used for the compiled
# Matlab code?
#
# Drop the -singleCompThread if you _want_ the resulting
# executable to have threaded math library support -- you'll
# want to submit such jobs with the "exclusive=1" flag to
# ensure your program has the whole node to itself!
#
MCR_RUNTIME_FLAGS	= "-nodesktop,-singleCompThread"

##
####
####
##

default: $(TARGET)

-include ../Makefile.inc

$(TARGET): $(SOURCE)

clean::
	$(RM) $(TARGET) run_$(TARGET).sh readme.txt requiredMCRProducts.txt mccExcludedFiles.log

install: $(TARGET) $(BINDIR)
	install $(TARGET) $(BINDIR)

-include ../Makefile.rules.post
