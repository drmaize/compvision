# Surface Estimation
Surface estimation is the process of taking a 3D stack and finding the depth of the surface for each pixel in a 2D view from above. This allows quantification of the depth of the pathogen and quantification of features that lie on the surface of the plant (e.g. stomata segmentation and locations). We use an active contour/snake optimization with uniformly initialized control points to perform this. 

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine, as well as Matlab 2021a on Ubuntu 20.04. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10 or Ubuntu. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

For Windows: ```./SurfaceEstimation.exe myStackIn.tif out```  
For Linux: ```./run_SurfaceEstimation.sh /usr/local/MATLAB/MATLAB_Runtime/v910  myStackIn.tif out```  
where  /usr/local/MATLAB/MATLAB_Runtime/v910 is the path to the Matlab Runtime (Linux requirement only)

where /usr/local/MATLAB/MATLAB_Runtime/v910 is the path to the Matlab Runtime installed (requirement for Linux only). 

The program will create two files: out.png and out.txt which contains the surface image and the surface depth values.
