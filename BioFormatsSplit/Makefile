##
## Produce a binary executable from the Matlab code in this
## directory.
##

SOURCES	= imagej-bioformats imagej-bioformats-vncstartup

default: dummy

-include ../Makefile.inc

dummy:

clean::

install: $(BINDIR) $(patsubst %,$(BINDIR)/%,$(SOURCES))

$(BINDIR)/%: %
	install $< $@

-include ../Makefile.rules.post
