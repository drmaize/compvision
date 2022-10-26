#
# Build the Singularity container for this Python code.
#

-include ../../Makefile.inc

CONTAINER_SIF	= segmentation.sif
CONTAINER_SDEF	= segmentation.sdef
CONTAINER_URL	= library://frey_at_udel_dot_edu/drmaize-compvision/segmentation.sif:latest

default: $(CONTAINER_SIF)

clean:
	$(RM) $(CONTAINER_SIF)

install: $(CONTAINER_SIF) $(LIBEXECDIR) $(BINDIR)
	install "$(CONTAINER_SIF)" "$(LIBEXECDIR)"
	install SegmentObjects.wrapper "$(BINDIR)/SegmentObjects"

ifeq ($(SEGMENTATION_CONTAINER_ACTION),build)
$(CONTAINER_SIF): $(CONTAINER_SDEF)
	./create.sh "$(CONTAINER_SIF)" "$(CONTAINER_SDEF)"
else
$(CONTAINER_SIF):
	singularity pull "$(CONTAINER_SIF)" "$(CONTAINER_URL)"
endif

-include ../../Makefile.rules.post
