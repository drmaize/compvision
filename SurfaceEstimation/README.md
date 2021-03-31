# Surface Estimation
Surface estimation is the process of taking a 3D stack and finding the depth of the surface for each pixel in a 2D view from above. This allows quantification of the depth of the pathogen and quantification of features that lie on the surface of the plant (e.g. stomata segmentation and locations). We use an active contour/snake optimization with uniformly initialized control points to perform this. 

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

```./SurfaceEstimation.exe myStackIn.tif out```
