#
# Dispatch the build process to whichever variant is selected
#

-include ../Makefile.inc

ifdef SEGMENTATION_BUILD_VARIANT

default:
	$(MAKE) -C $(SEGMENTATION_BUILD_VARIANT)

install:
	$(MAKE) -C $(SEGMENTATION_BUILD_VARIANT) install

clean:
	$(MAKE) -C $(SEGMENTATION_BUILD_VARIANT) clean

else

$(error No Segmentation build variant selected (SEGMENTATION_BUILD_VARIANT not set))

endif
