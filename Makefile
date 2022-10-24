##
## Top-level Makefile that drives all of the subprojects:
##

all:
	$(MAKE) -C Segmentation
	$(MAKE) -C QuantifyPhenotypes
	$(MAKE) -C SkeletonConnection
	$(MAKE) -C SurfaceEstimation
	$(MAKE) -C ThresholdAndSkeletonize

clean:
	$(MAKE) -C Segmentation clean
	$(MAKE) -C QuantifyPhenotypes clean
	$(MAKE) -C SkeletonConnection clean
	$(MAKE) -C SurfaceEstimation clean
	$(MAKE) -C ThresholdAndSkeletonize clean

install: $(PREFIX)
	$(MAKE) -C Segmentation install
	$(MAKE) -C QuantifyPhenotypes install
	$(MAKE) -C SkeletonConnection install
	$(MAKE) -C SurfaceEstimation install
	$(MAKE) -C ThresholdAndSkeletonize install
