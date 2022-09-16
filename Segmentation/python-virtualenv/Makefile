#
# Setup the Python virtual environment for this program and install a script
# wrapper that will allow us to execute it.
#

-include ../../Makefile.inc

default:

clean:

install:
	./create.sh --prefix "$(PREFIX)"
	install ../SegmentObjects.py "$(BINDIR)"
	install SegmentObjects.wrapper "$(BINDIR)/SegmentObjects"

-include ../../Makefile.rules.post
