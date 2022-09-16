

all:
	$(MAKE) -C Segmentation
	$(MAKE) -C QuantifyPhenotypes
	$(MAKE) -C SkeletonConnection
	$(MAKE) -C SurfaceEstimation

install: $(BINDIR)
	$(MAKE) -C Segmentation install-container
	$(MAKE) -C QuantifyPhenotypes install
	$(MAKE) -C SkeletonConnection install
	$(MAKE) -C SurfaceEstimation install
