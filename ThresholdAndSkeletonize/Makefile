#
# Dispatch the build process to whichever variant is selected
#

-include ../Makefile.inc

ifdef THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT

default:
	$(MAKE) -C $(THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT)

install:
	$(MAKE) -C $(THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT) install

clean:
	$(MAKE) -C $(THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT) clean

else

$(error No ThresholdAndSkeletonize build variant selected (THRESHOLD_AND_SKELETONIZE_BUILD_VARIANT not set))

endif
