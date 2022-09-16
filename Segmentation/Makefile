#
# Setup the Python virtual environment for this program and install a script
# wrapper that will allow us to execute it.
#

-include ../Makefile.inc

CONTAINER_SIF	= segmentation.sif
CONTAINER_SDEF	= segmentation.sdef

all: $(CONTAINER_SIF)

install-container: $(CONTAINER_SIF) $(LIBEXECDIR) $(BINDIR)
	install "$(CONTAINER_SIF)" "$(LIBEXECDIR)"
	install SegmentObjects.container "$(BINDIR)/SegmentObjects"

install-virtualenv:
	./conda-env-create.sh --prefix "$(PREFIX)"
	install SegmentObjects.py "$(BINDIR)"
	install SegmentObjects.virtualenv "$(BINDIR)/SegmentObjects"

$(CONTAINER_SIF): $(CONTAINER_SDEF)
	singularity build "$(CONTAINER_SIF)" "$(CONTAINER_SDEF)"

-include ../Makefile.rules.post

