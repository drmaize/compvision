##
## Install the Python virtualenv (if the target directory does not
## exist) and the tsk-filter.py program.
##

TSK_SCRIPT = tsk-filter.py
CONDA_ARGS = --channel intel

##
####
####
##

default:

-include ../../Makefile.inc

ifeq ($(SEGMENTATION_BUILD_VARIANT),python-virtualenv)
    VIRTUALENV = $(PREFIX)
else
    VIRTUALENV = $(PREFIX)/tsk-venv
endif

clean::

install: $(PREFIX)/$(VIRTUALENV) $(BINDIR)/$(TSK_SCRIPT)

$(BINDIR)/$(TSK_SCRIPT): $(TSK_SCRIPT) $(BINDIR)
	install --mode=0755 $(TSK_SCRIPT) $(BINDIR)

$(PREFIX)/$(VIRTUALENV):
	conda create --prefix="$(VIRTUALENV)" $(CONDA_ARGS) scikit-image=0.19.2

-include ../../Makefile.rules.post

