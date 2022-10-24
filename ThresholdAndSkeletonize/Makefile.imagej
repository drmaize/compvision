##
## Download and install the Fiji application for Linux;
## also installs the Bash driver script that constructs and
## executes macros.
##

# What is the name of the executable to be produced:
APPLICATION	= Fiji.app

# Where does the application come from?
SOURCE_URL	= "https://downloads.imagej.net/fiji/latest/fiji-linux64.zip"
SOURCE_ZIP	= fiji-linux64.zip

# Don't forget the Bash driver script:
BASH_SCRIPT	= imagej-filter

##
####
####
##

default: $(SOURCE_ZIP)

-include ../Makefile.inc

$(SOURCE_ZIP):
	curl -k --output $(SOURCE_ZIP) $(SOURCE_URL)

clean::
	$(RM) $(SOURCE_ZIP)

install: $(PREFIX)/$(APPLICATION) $(BINDIR)/$(BASH_SCRIPT)

$(BINDIR)/$(BASH_SCRIPT): $(BASH_SCRIPT) $(BINDIR)
	install --mode=0755 $(BASH_SCRIPT) $(BINDIR)

$(PREFIX)/$(APPLICATION): $(SOURCE_ZIP) $(PREFIX)
	unzip -o -d $(PREFIX) $(SOURCE_ZIP)
	rm -f $(BINDIR)/ImageJ-linux64
	ln --relative -s $(PREFIX)/$(APPLICATION)/ImageJ-linux64 $(BINDIR)/ImageJ-linux64

-include ../Makefile.rules.post

