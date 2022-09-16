#
# Build the Singularity container for this Python code.
#

-include ../../Makefile.inc

CONTAINER_SIF	= segmentation.sif
CONTAINER_SDEF	= segmentation.sdef

default: $(CONTAINER_SIF)

clean:
	$(RM) $(CONTAINER_SIF)

install: $(CONTAINER_SIF) $(LIBEXECDIR) $(BINDIR)
	install "$(CONTAINER_SIF)" "$(LIBEXECDIR)"
	install SegmentObjects.wrapper "$(BINDIR)/SegmentObjects"

$(CONTAINER_SIF): $(CONTAINER_SDEF)
	./create.sh "$(CONTAINER_SIF)" "$(CONTAINER_SDEF)"

-include ../../Makefile.rules.post
