#
# Dispatch the build process to whichever variant is selected
#

-include ../Makefile.inc

ifdef SEGMENTATION_BUILD_VARIANT

    ifeq ($(SEGMENTATION_BUILD_VARIANT),singularity-container)
    
default:
	$(MAKE) -C singularity-container

install:
	$(MAKE) -C singularity-container install

clean:
	$(MAKE) -C singularity-container clean

    else ifeq ($(SEGMENTATION_BUILD_VARIANT),python-virtualenv)
    
default:
	$(MAKE) -C python-virtualenv

install:
	$(MAKE) -C python-virtualenv install

clean:
	$(MAKE) -C python-virtualenv clean

    else
    
$(error Unhandled Segmentation build variant "$(SEGMENTATION_BUILD_VARIANT)")

    endif
else

$(error No Segmentation build variant selected (SEGMENTATION_BUILD_VARIANT not set))

endif
